require 'faraday'
require 'benchmark'

module RestRunner
  # Executes individual HTTP test cases with Fiber-based non-blocking IO.
  # Uses standard Faraday adapter with Fiber Scheduler cooperative scheduling.
  # @see https://github.com/socketry/async-http
  class Executor
    # Initialize executor with test specification.
    # @param test_data [Hash] Test configuration from parsed collection
    def initialize(test_data)
      @test_data = test_data
      @conn = build_async_connection
    end

    # Execute the test synchronously within the current Fiber context.
    # Returns result hash with name, success flag, status code, and latency.
    # @return [Hash] Result containing :name, :success, :status, :latency_ms, :error (optional)
    def run_test
      response = nil
      duration = Benchmark.realtime { response = execute_request }

      {
        name: @test_data[:name],
        success: validate_assertions(response),
        status: response.status,
        latency_ms: (duration * 1000).round(2)
      }
    rescue StandardError => e
      { name: @test_data[:name], success: false, error: e.message, status: 'ERR', latency_ms: 0 }
    end

    private

    # Build Faraday connection configured for optimal Fiber Scheduler integration.
    # Default Net::HTTP adapter is compatible with Ruby 3.4 Fiber Scheduler.
    # @return [Faraday::Connection] HTTP client configured for non-blocking IO
    def build_async_connection
      Faraday.new do |f|
        f.request :json
        f.response :json, content_type: /\bjson$/
        f.adapter :net_http  # Net::HTTP respects Fiber Scheduler in Ruby 3.4+
      end
    end

    # Execute HTTP request without blocking current Fiber.
    # @return [Faraday::Response] HTTP response object
    def execute_request
      @conn.run_request(
        @test_data[:method].downcase.to_sym,
        @test_data[:endpoint],
        @test_data[:body],
        @test_data[:headers]
      )
    end

    # Validate response against test assertions.
    # @param response [Faraday::Response] HTTP response to validate
    # @return [Boolean] true if all assertions pass
    def validate_assertions(response)
      assertions = @test_data[:assertions] || {}

      # 1. Check Status Code
      if assertions[:status] && response.status != assertions[:status]
        return false
      end

      # 2. Check body contains string (if specified)
      if assertions[:body_contains]
        body_text = response.body.is_a?(String) ? response.body : response.body.to_s
        return false unless body_text.include?(assertions[:body_contains])
      end

      true
    end
  end
end