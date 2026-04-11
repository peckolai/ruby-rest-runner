module RestRunner
  module Commands
    # Interactive environment selector - shows available environments and their variables.
    class EnvUse
      # List and interactively select an environment to use.
      # @param env_name [String, nil] Environment name to select (or prompt if nil)
      # @return [void]
      def execute(env_name = nil)
        manager = EnvironmentManager.new

        unless env_name
          # Interactive selection
          available = manager.available_environments
          
          if available.empty?
            puts "\n⚠️  No environments found in config/envs/"
            puts "   Create .yml environment files or use: rest-run import-env <postman_env.json>"
            return
          end

          prompt = TTY::Prompt.new
          env_name = prompt.select("Select environment:", available)
        end

        # Load and display selected environment
        vars = manager.load_environment(env_name)

        puts "\n"
        puts colorize_text("Environment: #{env_name}", :green)
        puts colorize_text("-" * 60, :green)

        if vars.empty?
          puts "  (no variables)"
        else
          vars.each do |key, value|
            # Mask sensitive values (likely tokens/passwords)
            masked_value = mask_value(key.to_s, value.to_s)
            puts "  #{key}: #{masked_value}"
          end
        end

        puts "\n"
        puts "✓ Environment loaded. Use with:"
        puts "  rest-run exec -e #{env_name} collections/your_collection.yml"
        puts "\n"
      end

      private

      # Mask sensitive variable values in output.
      # @param key [String] Variable name
      # @param value [String] Variable value
      # @return [String] Masked or original value
      def mask_value(key, value)
        sensitive_patterns = %w[key token password secret pwd auth credential api_key]
        is_sensitive = sensitive_patterns.any? { |pattern| key.downcase.include?(pattern) }
        
        if is_sensitive && value.length > 4
          value[0..3] + "*" * (value.length - 4)
        else
          value
        end
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
