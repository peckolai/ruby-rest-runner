module RestRunner
  # Mask sensitive values in output to prevent leaking credentials.
  class SecretsMasker
    # Patterns that indicate a variable is sensitive
    SENSITIVE_PATTERNS = %w[
      key password token secret pwd auth credential
      api_key bearer oauth jwt hash hmac
      private_key client_secret access_token refresh_token
    ].freeze

    # Mask sensitive values in a string.
    # @param text [String] Text to mask
    # @return [String] Text with sensitive values masked
    def self.mask_string(text)
      new.mask_string(text)
    end

    # Mask sensitive values in a hash (recursive).
    # @param hash [Hash] Hash to mask
    # @return [Hash] Hash with sensitive values masked
    def self.mask_hash(hash)
      new.mask_hash(hash)
    end

    # Mask a single key-value pair.
    # @param key [String, Symbol] Key name
    # @param value [String] Value to potentially mask
    # @return [String] Masked or original value
    def self.mask_value(key, value)
      new.mask_value(key, value)
    end

    # Mask sensitive values in a string (look for patterns like key=value).
    # @param text [String] Text to mask
    # @return [String] Masked text
    def mask_string(text)
      return text unless text.is_a?(String)

      # Mask patterns like: Authorization: Bearer token123
      text.gsub(/([Aa]uthori[sz]ation:\s*Bearer|[Aa]uthori[sz]ation:\s*Basic)\s+[\w\-\.]+/) do |match|
        match.gsub(/[\w\-\.]+$/, "****")
      end
    end

    # Mask sensitive key-value pairs in a hash (recursive).
    # @param hash [Hash] Hash to process
    # @return [Hash] Hash with masked values
    def mask_hash(hash)
      return hash unless hash.is_a?(Hash)

      masked = {}
      hash.each do |key, value|
        masked_key = key.to_s.downcase

        if value.is_a?(Hash)
          masked[key] = mask_hash(value)
        elsif value.is_a?(Array)
          masked[key] = value.map { |v| v.is_a?(Hash) ? mask_hash(v) : mask_value(masked_key, v.to_s) }
        else
          masked[key] = mask_value(masked_key, value.to_s)
        end
      end

      masked
    end

    # Mask a single value if the key indicates sensitive data.
    # @param key [String] Key name
    # @param value [String] Value to mask
    # @return [String] Masked or original value
    def mask_value(key, value)
      key_str = key.to_s.downcase

      # Check if key matches sensitive patterns
      is_sensitive = SENSITIVE_PATTERNS.any? { |pattern| key_str.include?(pattern) }

      if is_sensitive && value.length > 4
        # Keep first 4 chars, mask the rest
        value[0..3] + "*" * (value.length - 4)
      elsif is_sensitive && value.length > 0
        # Short values: show 1 char + asterisks
        value[0] + "*" * (value.length - 1)
      else
        value
      end
    end
  end
end
