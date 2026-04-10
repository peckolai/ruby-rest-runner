module RestRunner
  class VariableResolver
    # Regex to match ${VARIABLE_NAME}
    VAR_REGEX = /\${(?<name>[^}]+)}/

    def self.resolve!(data)
      case data
      when Hash
        data.transform_values! { |v| resolve!(v) }
      when Array
        data.map! { |v| resolve!(v) }
      when String
        data.gsub(VAR_REGEX) do |match|
          var_name = Regexp.last_match[:name]
          ENV[var_name] || match # Fallback to original string if ENV not set
        end
      else
        data
      end
    end
  end
end