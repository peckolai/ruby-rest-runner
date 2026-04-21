require 'tty-prompt'
require_relative '../../../hooks/auth_helper'

module RestRunner
  module Commands
    # Interactively run a single HTTP request
    class Oneshot
      def initialize(options = {})
        @options = options
        @prompt = TTY::Prompt.new
      end

      def execute
        method = @prompt.select("HTTP method:", %w[GET POST PUT PATCH DELETE HEAD OPTIONS])
        url = @prompt.ask("Request URL:", required: true)
        headers = {}
        while @prompt.yes?("Add a header?")
          key = @prompt.ask("Header name:", required: true)
          value = @prompt.ask("Header value:", required: true)
          headers[key] = value
        end
        cookies = {}
        if @prompt.yes?("Add cookies?")
          while @prompt.yes?("Add a cookie?")
            key = @prompt.ask("Cookie name:", required: true)
            value = @prompt.ask("Cookie value:", required: true)
            cookies[key] = value
          end
        end
        body = nil
        if %w[POST PUT PATCH].include?(method)
          body = @prompt.multiline("Request body (end with empty line):").join("\n")
        end
        # Apply authentication hook
        AuthHelper.apply_auth!(headers, @prompt)
        # Merge cookies into headers if present
        unless cookies.empty?
          headers['Cookie'] = cookies.map { |k, v| "#{k}=#{v}" }.join('; ')
        end
        # Build test_spec for Executor
        test_spec = {
          name: "oneshot",
          method: method,
          endpoint: url,
          headers: headers,
          body: body
        }
        debug = @options[:debug] || false
        Executor.new(test_spec, debug: debug).run_test
      end
    end
  end
end
