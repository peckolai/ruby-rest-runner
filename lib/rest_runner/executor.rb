require 'rouge'
require 'json'
require 'faraday'
require 'benchmark'


module RestRunner
  # Executes individual HTTP test cases with Fiber-based non-blocking IO.
  # Uses standard Faraday adapter with Fiber Scheduler cooperative scheduling.
  # @see https://github.com/socketry/async-http
  class Executor
    # Initialize executor with test specification.
    # @param test_data [Hash] Test configuration from parsed collection
    # @param debug [Boolean] Whether to print debug info
    def initialize(test_data, debug: false)
      @test_data = test_data
      @debug = debug
      @conn = build_async_connection
    end

    # Execute the test synchronously within the current Fiber context.
    # Returns result hash with name, success flag, status code, and latency.
    # @return [Hash] Result containing :name, :success, :status, :latency_ms, :error (optional)
    def run_test
      response = nil
      duration = Benchmark.realtime { response = execute_request }

      if @debug
        print_debug_request
        print_debug_response(response)
      end

      {
        name: @test_data[:name],
        success: validate_assertions(response),
        status: response.status,
        latency_ms: (duration * 1000).round(2),
        body: response.body
      }
    rescue StandardError => e
      { name: @test_data[:name], success: false, error: e.message, status: 'ERR', latency_ms: 0 }
    end

    # Print the HTTP request details for debugging
    def print_debug_request
      output = []
      output << "\n\e[36m[DEBUG] HTTP REQUEST\e[0m"
      output << "  Method:   #{@test_data[:method].to_s.upcase}"
      output << "  Endpoint: #{@test_data[:endpoint]}"
      if @test_data[:headers] && !@test_data[:headers].empty?
        output << "  Headers:  "
        @test_data[:headers].each { |k, v| output << "    #{k}: #{v}" }
      end
      if @test_data[:body]
        output << "  Body:     "
        output << (@test_data[:body].is_a?(String) ? @test_data[:body] : @test_data[:body].to_s)
      end
      paginate_output(output.join("\n"))
    end

    # Print the HTTP response details for debugging
    def print_debug_response(response)
      output = []
      output << "\e[35m[DEBUG] HTTP RESPONSE\e[0m"
      output << "  Status:   #{response.status}"
      if response.headers && !response.headers.empty?
        output << "  Headers:  "
        response.headers.each { |k, v| output << "    #{k}: #{v}" }
      end
      output << "  Body:     "
      begin
        json_obj = response.body.is_a?(String) ? JSON.parse(response.body) : response.body
        pretty_json = JSON.pretty_generate(json_obj)
        formatter = Rouge::Formatters::Terminal256.new
        lexer = Rouge::Lexers::JSON.new
        output << formatter.format(lexer.lex(pretty_json))
      rescue => _e
        output << (response.body.is_a?(String) ? response.body : response.body.to_s)
      end
      output << ""
      paginate_output(output.join("\n"))
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

    # Paginate output using configured pager or fallback to direct output.
    # Respects $PAGER environment variable or defaults to 'less -R'.
    # Falls back to direct STDOUT if pager is unavailable or fails.
    # @param text [String] The text to display
    def paginate_output(text)
      pager = ENV['PAGER'] || 'less -R'
      IO.popen(pager, 'w') { |io| io.puts text }
    rescue Errno::ENOENT, Errno::EPIPE
      # Pager not found or pipe broken, fall back to direct output
      puts text
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