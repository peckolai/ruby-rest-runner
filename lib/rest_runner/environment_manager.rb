require 'yaml'

module RestRunner
  # Manage environment loading and variable resolution.
  # Handles loading YAML environment files and injecting variables into collections.
  class EnvironmentManager
    # Initialize with optional active environment name.
    # @param env_name [String, nil] Active environment name or path
    def initialize(env_name = nil)
      @env_name = env_name
      @env_vars = {}
      load_environment if env_name
    end

    # Load environment variables from YAML file.
    # @param env_name [String] Environment name (without .yml) or full path
    # @return [Hash] Loaded environment variables
    def load_environment(env_name = nil)
      env_name ||= @env_name
      return {} unless env_name

      # First check if it's a full path
      if File.exist?(env_name)
        env_path = env_name
      else
        # Otherwise look in config/envs/
        env_path = File.join(Dir.pwd, "config", "envs", "#{env_name}.yml")
      end

      unless File.exist?(env_path)
        puts "⚠️  Environment file not found: #{env_path}"
        return {}
      end

      begin
        @env_vars = YAML.load_file(env_path, symbolize_names: true) || {}
        @env_name = env_name
        @env_vars
      rescue Psych::SyntaxError => e
        puts "❌ YAML Syntax Error in #{env_path}: #{e.message}"
        {}
      end
    end

    # Get all currently loaded environment variables.
    # @return [Hash] Environment variables
    def variables
      @env_vars
    end

    # Get a single environment variable.
    # @param key [String] Variable key
    # @return [String, nil] Variable value or nil if not found
    def get(key)
      @env_vars[key.to_sym] || @env_vars[key.to_s]
    end

    # Set an environment variable (in memory only, not persisted).
    # @param key [String] Variable key
    # @param value [String] Variable value
    # @return [void]
    def set(key, value)
      @env_vars[key.to_sym] = value
    end

    # Get currently active environment name.
    # @return [String, nil] Environment name
    def current_env
      @env_name
    end

    # List all available environment files.
    # @return [Array<String>] Array of environment names (without .yml extension)
    def available_environments
      envs_dir = File.join(Dir.pwd, "config", "envs")
      return [] unless Dir.exist?(envs_dir)

      files = Dir.glob(File.join(envs_dir, "*.yml")) +
              Dir.glob(File.join(envs_dir, "*.yaml"))
      files.map { |f| File.basename(f, File.extname(f)) }
    end

    # Merge environment variables with external vars (ENV takes precedence).
    # @param collection [Hash] REST collection hash
    # @return [Hash] Collection with vars merged and resolved
    def apply_to_collection(collection)
      # Deep copy collection
      merged = Marshal.load(Marshal.dump(collection))

      # Merge environment vars: ENV > active_env > collection defaults
      all_vars = @env_vars.dup
      
      # Also load from actual ENV if available
      @env_vars.each_key do |key|
        env_var = ENV[key.to_s]
        all_vars[key] = env_var if env_var
      end

      # Push vars into VariableResolver
      merged[:_variables] = all_vars
      merged
    end
  end
end
