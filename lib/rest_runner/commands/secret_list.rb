module RestRunner
  module Commands
    # List all stored secrets from keychain.
    class SecretList
      # List all stored secrets.
      # @return [void]
      def execute
        keychain = KeychainIntegration.new
        keys = keychain.list_keys

        puts "\n"
        puts colorize_text("Stored Secrets (#{keychain.backend})", :cyan)
        puts colorize_text("-" * 60, :cyan)

        if keys.empty?
          puts "  (no secrets stored)"
        else
          keys.each do |key|
            puts "  • #{key}"
          end
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
