module RestRunner
  module Commands
    # Manage sensitive secrets in system keychain.
    # Supports macOS Keychain, pass (Linux), and local encrypted storage.
    class SecretStore
      # Store a secret securely.
      # @param key [String] Secret key/name
      # @param value [String, nil] Secret value (prompt if nil)
      # @return [void]
      def execute(key, value = nil)
        keychain = KeychainIntegration.new

        puts "\n"
        puts colorize_text("Storing Secret in #{keychain.backend}", :cyan)

        # Prompt for value if not provided
        if value.nil?
          prompt = TTY::Prompt.new
          value = prompt.mask("Secret value (hidden):", show: false)
        end

        # Store in keychain
        if keychain.store(key, value)
          puts "✓ Secret '#{key}' stored successfully"
          puts "  Backend: #{keychain.backend}"
          puts "  Location: #{keychain.backend == 'Local .env.local' ? '.env.local (add to .gitignore)' : 'System Keychain'}"
        else
          puts "❌ Failed to store secret"
        end

        puts "\n"
      end

      private

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
