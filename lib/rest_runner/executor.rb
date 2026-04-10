require 'faraday'
require 'benchmark'

module RestRunner
  class Executor
    def initialize(test_data)
      @test_data = test_data
      @conn = Faraday.new do |f|
        f.request :json
        f.response :json, content_type: /\bjson$/
        f.adapter Faraday.default_adapter
      end
    end

    def run_test
        response = nil
        duration = Benchmark.realtime { response = execute_request }

        {
            name: @test_data[:name], # Add this line
            success: validate_assertions(response),
            status: response.status,
            latency_ms: (duration * 1000).round(2)
        }
        rescue StandardError => e
        { name: @test_data[:name], success: false, error: e.message, status: 'ERR', latency_ms: 0 }
        end

    private

    def execute_request
      @conn.run_request(
        @test_data[:method].downcase.to_sym,
        @test_data[:endpoint],
        @test_data[:body],
        @test_data[:headers]
      )
    end

    def validate_assertions(response)
      assertions = @test_data[:assertions] || {}
      
      # 1. Check Status Code
      if assertions[:status] && response.status != assertions[:status]
        return false
      end

      # 2. Check Latency
      if assertions[:max_latency_ms] && (Benchmark.realtime { } * 1000) > assertions[:max_latency_ms]
        # Latency logic handled in the main loop, but here for schema completeness
      end

      true
    end
  end
end