module RestRunner
  # Resolve variables in collections using environment vars and custom variable maps.
  # Supports ${VARIABLE_NAME} syntax for substitution.
  class VariableResolver
    # Regex to match ${VARIABLE_NAME}
    VAR_REGEX = /\${(?<name>[^}]+)}/

    # Resolve all variables in data structure.
    # Priority: custom_vars > ENV > original string
    # @param data [Hash, Array, String] Data to resolve
    # @param custom_vars [Hash] Optional custom variable map (typically from environment file)
    # @return [Hash, Array, String] Resolved data
    def self.resolve!(data, custom_vars = nil)
      resolver = new(custom_vars)
      resolver.resolve(data)
    end

    # Initialize resolver with optional custom variables.
    # @param custom_vars [Hash] Custom variable map
    def initialize(custom_vars = nil)
      @custom_vars = custom_vars || {}
    end

    # Resolve variables in data structure.
    # @param data [Hash, Array, String] Data to resolve
    # @return [Hash, Array, String] Resolved data
    def resolve(data)
      case data
      when Hash
        data.each { |k, v| data[k] = resolve(v) }
        data
      when Array
        data.map! { |v| resolve(v) }
      when String
        resolve_string(data)
      else
        data
      end
    end

    private

    # Resolve variables in a string.
    # @param str [String] String potentially containing ${VAR} placeholders
    # @return [String] String with variables substituted
    def resolve_string(str)
      str.gsub(VAR_REGEX) do |match|
        var_name = Regexp.last_match[:name]
        # Priority: custom vars > ENV
        @custom_vars[var_name.to_sym] || @custom_vars[var_name.to_s] || ENV[var_name] || match
      end
    end
  end
end