require 'json'

module RestRunner
  module Commands
    # Parse Postman environment export format into RestRunner YAML structure.
    # Handles both Postman v2 and v3 environment formats.
    class PostmanEnvParser
      # Parse a Postman environment file.
      # @param path [String] Path to Postman environment JSON file
      # @return [Hash, nil] Hash with :name and :variables keys, or nil on error
      def parse(path)
        begin
          data = JSON.parse(File.read(path), symbolize_names: true)
          
          name = extract_name(data)
          variables = extract_variables(data)

          {
            name: name,
            variables: variables
          }
        rescue JSON::ParserError => e
          puts "❌ JSON Parse Error: #{e.message}"
          nil
        rescue => e
          puts "❌ Error parsing environment: #{e.message}"
          nil
        end
      end

      private

      # Extract environment name from Postman format.
      # @param data [Hash] Parsed Postman environment JSON
      # @return [String] Environment name
      def extract_name(data)
        data[:name] || data["name"] || "imported_environment"
      end

      # Extract variables from Postman environment.
      # Handles both variable array format and object format.
      # @param data [Hash] Parsed Postman environment JSON
      # @return [Hash] Variables hash
      def extract_variables(data)
        variables = {}

        # Check for variables array (Postman v2/v3 format)
        if data[:values] || data["values"]
          values = data[:values] || data["values"]
          
          # values is an array of {key, value, type} objects
          if values.is_a?(Array)
            values.each do |var|
              key = var[:key] || var["key"]
              value = var[:value] || var["value"]
              
              # Handle initial value vs current value
              if var[:initialValue]
                value = var[:initialValue]
              end

              if key && value
                variables[key] = value.to_s
              end
            end
          end
        end

        # Check for variables object (alternative format)
        if data[:variables] || data["variables"]
          vars_obj = data[:variables] || data["variables"]
          
          if vars_obj.is_a?(Hash)
            vars_obj.each do |key, val|
              # val might be a string or a hash with key/value
              if val.is_a?(Hash)
                value = val[:value] || val["value"]
                variables[key] = value.to_s if value
              else
                variables[key] = val.to_s
              end
            end
          end
        end

        variables
      end
    end
  end
end
