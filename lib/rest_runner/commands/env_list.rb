module RestRunner
  module Commands
    # List all available environment configurations.
    # Reads from config/envs/ directory.
    class EnvList
      # List environments with descriptions.
      # @return [void]
      def execute
        env_dir = File.join(Dir.pwd, "config", "envs")

        if !Dir.exist?(env_dir)
          puts "\n⚠️  No config/envs directory found. Create one to store environment files."
          return
        end

        env_files = Dir.glob(File.join(env_dir, "*.yml")) + Dir.glob(File.join(env_dir, "*.yaml"))

        if env_files.empty?
          puts "\n⚠️  No environment files found in config/envs/"
          puts "   Create .yml or .yaml files (e.g., development.yml, staging.yml, production.yml)"
          return
        end

        puts "\n"
        puts colorize_text("Available Environments", :cyan)
        puts colorize_text("-" * 60, :cyan)

        env_files.each do |file|
          env_name = File.basename(file, File.extname(file))
          file_size = File.size(file)
          puts "  • #{env_name.ljust(20)} (#{file_size} bytes)"
        end

        puts "\n"
      end

      private

      # Helper to colorize text for terminal display.
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
