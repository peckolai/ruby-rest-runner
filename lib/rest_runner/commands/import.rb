require 'json'
require 'yaml'

module RestRunner
  module Commands
    # Import REST collections from Postman v2.1 or OpenAPI 3.1 formats.
    # Auto-detects format and converts to native RestRunner YAML.
    class Import
      # Import a collection from external format.
      # @param source_path [String] Path to Postman or OpenAPI file
      # @param output_path [String, nil] Output YAML path (default: collections/imported_*.yml)
      # @return [void]
      def execute(source_path, output_path = nil)
        unless File.exist?(source_path)
          puts "\n❌ File not found: #{source_path}"
          return
        end

        puts "\n"
        puts colorize_text("Importing collection from #{File.basename(source_path)}", :cyan)

        # Detect format
        format = detect_format(source_path)
        puts "Detected format: #{colorize_text(format.upcase, :green)}"

        # Parse based on format
        collection = case format
                     when :postman
                       PostmanParser.new.parse(source_path)
                     when :openapi
                       OpenapiParser.new.parse(source_path)
                     when :yaml
                       YAML.load_file(source_path, symbolize_names: true)
                     else
                       puts "❌ Unknown format"
                       return
                     end

        # Generate output filename
        output_path ||= generate_output_path(source_path)

        # Ensure collections directory exists
        collections_dir = File.join(Dir.pwd, "collections")
        Dir.mkdir(collections_dir) unless Dir.exist?(collections_dir)

        # Write to YAML
        output_full_path = File.join(collections_dir, output_path)
        File.write(output_full_path, YAML.dump(collection))

        puts "\n✓ Collection imported successfully"
        puts "  Output: #{output_full_path}"
        puts "  Tests: #{collection[:tests]&.length || 0}"
        puts "\n"
      end

      private

      # Auto-detect format based on file content.
      # @param path [String] File path
      # @return [Symbol] Format (:postman, :openapi, :yaml)
      def detect_format(path)
        content = File.read(path)
        
        # Try JSON first (Postman or OpenAPI)
        begin
          data = JSON.parse(content)
          
          if data['info'] && data['item']
            return :postman  # Postman Collection v2.1
          elsif data['openapi'] || data['swagger']
            return :openapi  # OpenAPI 3.1 or Swagger 2.0
          end
        rescue JSON::ParserError
          # Not JSON, try YAML
        end

        # Try YAML (could be OpenAPI or RestRunner YAML)
        begin
          data = YAML.load(content, symbolize_names: true)
          
          # Check if it's OpenAPI
          if data[:openapi] || data[:swagger]
            return :openapi
          end
          
          return :yaml
        rescue Psych::SyntaxError
          # Not YAML either
        end

        :unknown
      end

      # Generate a safe output filename.
      # @param source_path [String] Source file path
      # @return [String] Output filename
      def generate_output_path(source_path)
        base_name = File.basename(source_path, File.extname(source_path))
        timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
        "imported_#{base_name}_#{timestamp}.yml"
      end

      # Helper to colorize text.
      # @param text [String] Text to colorize
      # @param color [Symbol] Color name
      # @return [String] ANSI-colored text
      def colorize_text(text, color)
        case color
        when :cyan
          "\e[36m#{text}\e[0m"
        when :green
          "\e[32m#{text}\e[0m"
        when :red
          "\e[31m#{text}\e[0m"
        else
          text
        end
      end
    end
  end
end
