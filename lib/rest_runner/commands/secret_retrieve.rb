module RestRunner
  module Commands
    # Retrieve a secret from keychain.
    class SecretRetrieve
      # Retrieve and display a secret.
      # @param key [String] Secret key to retrieve
      # @return [void]
      def execute(key)
        keychain = KeychainIntegration.new
        value = keychain.retrieve(key)

        if value
          puts "\n"
          puts colorize_text("Secret: #{key}", :green)
          puts colorize_text("-" * 60, :green)
          puts "  Value: #{mask_value(value)}"
          puts "\n"
        else
          puts "\n❌ Secret '#{key}' not found"
          puts "\n"
        end
      end

      private

      def mask_value(value)
        if value.length > 4
          value[0..3] + "*" * (value.length - 4)
        else
          "*" * value.length
        end
      end

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
