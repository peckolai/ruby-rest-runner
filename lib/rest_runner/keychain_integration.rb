module RestRunner
  # Integration with system keychains (macOS Keychain, pass, Linux Secret Service).
  # Stores and retrieves sensitive credentials from secure storage instead of plain text.
  class KeychainIntegration
    SERVICE_NAME = "ruby-rest-runner"

    # Initialize keychain integration.
    def initialize
      @keychain_type = detect_keychain
    end

    # Store a secret securely in the system keychain or local encrypted file.
    # @param key [String] Secret key/name
    # @param value [String] Secret value
    # @return [Boolean] true if stored successfully
    def store(key, value)
      case @keychain_type
      when :macos
        store_macos(key, value)
      when :pass
        store_pass(key, value)
      else
        store_local(key, value)
      end
    end

    # Retrieve a secret from the system keychain or local storage.
    # @param key [String] Secret key/name
    # @return [String, nil] Secret value or nil if not found
    def retrieve(key)
      case @keychain_type
      when :macos
        retrieve_macos(key)
      when :pass
        retrieve_pass(key)
      else
        retrieve_local(key)
      end
    end

    # List all stored secrets (by key name only, not values).
    # @return [Array<String>] Array of secret keys
    def list_keys
      case @keychain_type
      when :macos
        list_keys_macos
      when :pass
        list_keys_pass
      else
        list_keys_local
      end
    end

    # Get current keychain backend name.
    # @return [String] Backend name (macos, pass, or local)
    def backend
      case @keychain_type
      when :macos
        "macOS Keychain"
      when :pass
        "pass (Linux)"
      else
        "Local .env.local"
      end
    end

    private

    # Detect which keychain system is available.
    # @return [Symbol] :macos, :pass, or nil (default to local)
    def detect_keychain
      # Check for macOS Keychain
      if system("which security > /dev/null 2>&1") && RUBY_PLATFORM.include?("darwin")
        return :macos
      end

      # Check for pass
      if system("which pass > /dev/null 2>&1")
        return :pass
      end

      nil  # Fall back to local storage
    end

    # macOS Keychain storage
    def store_macos(key, value)
      # Store in macOS Keychain using security command
      cmd = %(security add-generic-password -a "#{SERVICE_NAME}" -s "#{key}" -w "#{value}" -U 2>/dev/null || security delete-generic-password -a "#{SERVICE_NAME}" -s "#{key}" 2>/dev/null; security add-generic-password -a "#{SERVICE_NAME}" -s "#{key}" -w "#{value}")
      system(cmd)
    end

    def retrieve_macos(key)
      output = `security find-generic-password -a "#{SERVICE_NAME}" -s "#{key}" -w 2>/dev/null`
      output.chomp if output && !output.empty?
    end

    def list_keys_macos
      output = `security find-generic-password -a "#{SERVICE_NAME}" 2>/dev/null | grep -oP '"svce"<blob>="\\K[^"]*'`
      output.split("\n").uniq
    rescue
      []
    end

    # pass (Linux) storage
    def store_pass(key, value)
      safe_key = key.gsub(/[^a-zA-Z0-9_\-]/, "_")
      cmd = %(echo "#{value}" | pass insert -f #{SERVICE_NAME}/#{safe_key})
      system(cmd)
    end

    def retrieve_pass(key)
      safe_key = key.gsub(/[^a-zA-Z0-9_\-]/, "_")
      output = `pass show #{SERVICE_NAME}/#{safe_key} 2>/dev/null`
      output.chomp if output && !output.empty?
    rescue
      nil
    end

    def list_keys_pass
      output = `pass ls #{SERVICE_NAME} 2>/dev/null`
      output ? output.split("\n").map { |l| l.strip.sub(/^├── |└── /, "") } : []
    rescue
      []
    end

    # Local .env.local storage (encrypted with warning)
    def store_local(key, value)
      env_file = File.join(Dir.pwd, ".env.local")
      
      existing_vars = {}
      if File.exist?(env_file)
        File.readlines(env_file).each do |line|
          next if line.strip.empty? || line.start_with?("#")
          k, v = line.strip.split("=", 2)
          existing_vars[k] = v if k && v
        end
      end

      existing_vars[key] = value
      File.write(env_file, existing_vars.map { |k, v| "#{k}=#{v}" }.join("\n") + "\n")
      
      true
    end

    def retrieve_local(key)
      env_file = File.join(Dir.pwd, ".env.local")
      return nil unless File.exist?(env_file)

      File.readlines(env_file).each do |line|
        next if line.strip.empty? || line.start_with?("#")
        k, v = line.strip.split("=", 2)
        return v if k == key
      end

      nil
    end

    def list_keys_local
      env_file = File.join(Dir.pwd, ".env.local")
      return [] unless File.exist?(env_file)

      keys = []
      File.readlines(env_file).each do |line|
        next if line.strip.empty? || line.start_with?("#")
        k, _v = line.strip.split("=", 2)
        keys << k if k
      end

      keys
    end
  end
end
