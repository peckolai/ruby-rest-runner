require 'json'
require 'yaml'

module RestRunner
  module Commands
    # Import environment variables from Postman environment export.
    class ImportEnv
      # Import a Postman environment file.
      # @param source_path [String] Path to Postman environment JSON file
      # @param output_name [String, nil] Output environment name (default: auto-generated)
      # @return [void]
      def execute(source_path, output_name = nil)
        unless File.exist?(source_path)
          puts "\n❌ File not found: #{source_path}"
          return
        end

        puts "\n"
        puts colorize_text("Importing environment from #{File.basename(source_path)}", :cyan)

        # Parse Postman environment
        env_data = PostmanEnvParser.new.parse(source_path)
        
        if env_data.nil?
          puts "❌ Failed to parse environment file"
          return
        end

        # Generate output filename
        output_name ||= generate_output_name(source_path, env_data[:name])

        # Ensure config/envs directory exists
        envs_dir = File.join(Dir.pwd, "config", "envs")
        Dir.mkdir(File.join(Dir.pwd, "config")) unless Dir.exist?(File.join(Dir.pwd, "config"))
        Dir.mkdir(envs_dir) unless Dir.exist?(envs_dir)

        # Write environment to YAML
        output_full_path = File.join(envs_dir, output_name)
        File.write(output_full_path, YAML.dump(env_data[:variables]))

        puts "\n✓ Environment imported successfully"
        puts "  Name: #{env_data[:name]}"
        puts "  Output: #{output_full_path}"
        puts "  Variables: #{env_data[:variables].length}"
        puts "\n"
      end

      private

      # Generate a safe environment filename.
      # @param source_path [String] Source file path
      # @param env_name [String] Environment name from Postman
      # @return [String] Output filename
      def generate_output_name(source_path, env_name)
        safe_name = env_name.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/^_|_$/, "")
        "#{safe_name}.yml"
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
