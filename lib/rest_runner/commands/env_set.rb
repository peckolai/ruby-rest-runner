module RestRunner
  module Commands
    # Set environment variables interactively using tty-prompt.
    # Stores in config/envs/ directory for future reference.
    class EnvSet
      # Set a single environment variable interactively.
      # @param name [String, nil] Variable name (prompt if nil)
      # @param value [String, nil] Variable value (prompt if nil)
      # @return [void]
      def execute(name = nil, value = nil)
        prompt = TTY::Prompt.new

        # Prompt for variable name if not provided
        name ||= prompt.ask("Environment variable name:", required: true)

        # Prompt for value if not provided (with mask for sensitive vars)
        if value.nil?
          is_sensitive = prompt.yes?("Is this a sensitive value (token/password)? Display as *****?")
          value = prompt.mask("Environment variable value:", show: false) if is_sensitive
          value ||= prompt.ask("Environment variable value:")
        end

        # Store in ENV temporarily for this session
        ENV[name] = value

        # Save to a local .env.development or similar file (optional persistence)
        env_file = File.join(Dir.pwd, ".env.local")
        
        existing_vars = {}
        if File.exist?(env_file)
          File.readlines(env_file).each do |line|
            next if line.strip.empty? || line.start_with?("#")
            key, val = line.strip.split("=", 2)
            existing_vars[key] = val if key && val
          end
        end

        existing_vars[name] = value
        File.write(env_file, existing_vars.map { |k, v| "#{k}=#{v}" }.join("\n") + "\n")

        puts "\n"
        puts "✓ Environment variable '#{name}' set successfully"
        puts "  Stored in: #{env_file}"
        puts "  Current value: #{value.length > 20 ? '***' : value}"
        puts "\n"
      end
    end
  end
end
