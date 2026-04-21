# frozen_string_literal: true

# AuthHelper provides a hook for injecting authentication headers or tokens.
# This is called by the Oneshot command and other scenarios to allow custom auth logic.
#
# To customize, edit this file. Example: fetch a token from ENV, keychain, or prompt.
module AuthHelper
  # @param headers [Hash] The headers hash to be mutated
  # @param prompt [TTY::Prompt] The prompt instance for interactive auth
  # @return [void]
  def self.apply_auth!(headers, prompt)
    # Example: Bearer token from ENV or prompt
    token = ENV["ONESHOT_AUTH_TOKEN"] || prompt.ask("Auth token (Bearer):", echo: false)
    if token && !token.strip.empty?
      headers["Authorization"] = "Bearer #{token.strip}"
    end
    # Add more custom logic as needed
  end
end
