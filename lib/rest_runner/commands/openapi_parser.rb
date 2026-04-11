require 'json'
require 'yaml'

module RestRunner
  module Commands
    # Parse OpenAPI 3.1 format into RestRunner YAML structure.
    class OpenapiParser
      # Parse an OpenAPI specification file.
      # @param path [String] Path to OpenAPI YAML or JSON file
      # @return [Hash] RestRunner collection hash
      def parse(path)
        # Load YAML or JSON
        content = File.read(path)
        data = if path.end_with?('.json')
                 JSON.parse(content, symbolize_names: true)
               else
                 YAML.load(content, symbolize_names: true)
               end

        {
          name: extract_name(data),
          description: extract_description(data),
          tests: extract_tests(data)
        }
      end

      private

      # Extract API title from OpenAPI info.
      # @param data [Hash] Parsed OpenAPI spec
      # @return [String] API title
      def extract_name(data)
        data.dig(:info, :title) || "OpenAPI Collection"
      end

      # Extract API description from OpenAPI info.
      # @param data [Hash] Parsed OpenAPI spec
      # @return [String] API description
      def extract_description(data)
        data.dig(:info, :description) || "Imported from OpenAPI"
      end

      # Extract tests from OpenAPI paths and operations.
      # @param data [Hash] Parsed OpenAPI spec
      # @return [Array<Hash>] Array of test specifications
      def extract_tests(data)
        paths = data[:paths] || {}
        server_url = extract_base_url(data)
        tests = []

        paths.each do |path_key, path_item|
          next unless path_item.is_a?(Hash)

          %w[get post put delete patch options head].each do |method|
            operation = path_item[method.to_sym]
            next unless operation

            test = parse_operation(method.upcase, path_key, operation, server_url)
            tests << test if test
          end
        end

        tests
      end

      # Extract base server URL from OpenAPI servers.
      # @param data [Hash] Parsed OpenAPI spec
      # @return [String] Base URL
      def extract_base_url(data)
        servers = data[:servers] || []
        return "https://api.example.com" if servers.empty?

        server = servers.first
        url = server[:url] || "https://example.com"
        # Replace variables with dummy values if present
        (server[:variables] || {}).each do |var_name, var_obj|
          default = var_obj[:default] || "value"
          url = url.gsub("{#{var_name}}", default)
        end

        url
      end

      # Parse a single OpenAPI operation into a test.
      # @param method [String] HTTP method (GET, POST, etc.)
      # @param path [String] API path
      # @param operation [Hash] OpenAPI operation object
      # @param base_url [String] Base server URL
      # @return [Hash] Test specification
      def parse_operation(method, path, operation, base_url)
        endpoint = build_endpoint(base_url, path, operation)
        
        test = {
          name: operation[:summary] || operation[:operationId] || "#{method} #{path}",
          method: method,
          endpoint: endpoint,
          headers: extract_headers(operation),
          body: extract_request_body(operation),
          assertions: extract_response_assertions(operation)
        }

        test.compact!
        test
      end

      # Build full endpoint URL.
      # @param base_url [String] Base URL
      # @param path [String] Path with OpenAPI variables
      # @param operation [Hash] Operation object
      # @return [String] Full endpoint URL
      def build_endpoint(base_url, path, operation)
        # Replace path parameters with placeholders
        endpoint_path = path.to_s.dup
        (operation[:parameters] || []).each do |param|
          if param[:in] == "path"
            default_value = param[:schema]&.dig(:default) || "value"
            endpoint_path = endpoint_path.gsub("{#{param[:name]}}", default_value.to_s)
          end
        end

        "#{base_url}#{endpoint_path}"
      end

      # Extract headers from operation parameters.
      # @param operation [Hash] OpenAPI operation
      # @return [Hash, nil] Headers or nil
      def extract_headers(operation)
        headers = {}
        (operation[:parameters] || []).each do |param|
          if param[:in] == "header"
            headers[param[:name]] = param[:schema]&.dig(:default) || "value"
          end
        end

        headers.empty? ? nil : headers
      end

      # Extract request body from OpenAPI operation.
      # @param operation [Hash] OpenAPI operation
      # @return [Hash, nil] Request body or nil
      def extract_request_body(operation)
        request_body = operation[:requestBody]
        return nil unless request_body

        # Get JSON content if available
        content = request_body[:content]&.dig(:"application/json")
        schema = content&.dig(:schema)

        return nil unless schema

        # Generate example from schema
        generate_example_from_schema(schema)
      end

      # Generate example data from OpenAPI schema.
      # @param schema [Hash] OpenAPI schema object
      # @return [Hash, String, nil] Example data
      def generate_example_from_schema(schema)
        case schema[:type]
        when "object"
          obj = {}
          (schema[:properties] || {}).each do |key, property|
            obj[key] = generate_example_from_schema(property)
          end
          obj.empty? ? nil : obj
        when "array"
          items = schema[:items] || {}
          [generate_example_from_schema(items)]
        when "string"
          schema[:example] || "example"
        when "number", "integer"
          schema[:example] || 0
        when "boolean"
          schema[:example] || true
        else
          nil
        end
      end

      # Extract response assertions from OpenAPI responses.
      # @param operation [Hash] OpenAPI operation
      # @return [Hash, nil] Assertions based on successful responses
      def extract_response_assertions(operation)
        responses = operation[:responses] || {}
        
        # Look for 200-level success responses
        success_response = responses["200"] || responses["201"] || responses["204"]
        return nil unless success_response

        # Extract status code for assertion
        status_code = success_response.key?("default") ? 200 : responses.keys.first.to_i

        {
          status: status_code
        }
      end
    end
  end
end
