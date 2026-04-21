
require "thor"
require "zeitwerk"
require "tty-table"
require "tty-prompt"
require "tty-progressbar"

# Setup autoloading so we don't have to manually 'require' every file
loader = Zeitwerk::Loader.for_gem
loader.setup

module RestRunner
  # Main CLI entry point using Thor framework.
  # Delegates to subcommands in lib/rest_runner/commands/
  class CLI < Thor
        desc "oneshot", "Interactively run a single HTTP request"
        method_option :debug, type: :boolean, default: false, desc: "Show full request and response details"
        def oneshot
          Commands::Oneshot.new(options).execute
        end

        # Silence Thor deprecation warning by explicitly setting exit_on_failure?
        def self.exit_on_failure?
          true
        end
    desc "exec PATH", "Execute a REST collection file (YAML format)"
    method_option :env, aliases: "-e", desc: "Path to environment variables file"
    method_option :verbose, type: :boolean, default: false, desc: "Show detailed output"
    method_option :debug, type: :boolean, default: false, desc: "Show full request and response details for each test"
    # Execute a collection file with optional environment override.
    # @param path [String] Path to YAML collection file
    def exec(path)
      Commands::Run.new(options).execute(path)
    end

    desc "env-list", "List all available environments"
    # List configured environments from config/envs/ directory.
    def env_list
      Commands::EnvList.new.execute
    end

    desc "env-use [NAME]", "Select and view an environment"
    # Interactively select or view a specific environment and its variables.
    # @param name [String, nil] Environment name (or prompt if omitted)
    def env_use(name = nil)
      Commands::EnvUse.new.execute(name)
    end

    desc "env-set NAME VALUE", "Set an environment variable"
    # Set a single environment variable interactively or via parameters.
    # @param name [String] Variable name
    # @param value [String] Variable value
    def env_set(name = nil, value = nil)
      Commands::EnvSet.new.execute(name, value)
    end

    desc "collections-list", "List available collection files"
    # Discover and list collection files from collections/ directory.
    def collections_list
      Commands::CollectionsList.new.execute
    end

    desc "import SOURCE [OUTPUT]", "Import a Postman v2.1 or OpenAPI 3.1 collection"
    method_option :output, aliases: "-o", desc: "Output YAML filename (default: auto-generated)"
    # Import collection from external format (Postman/OpenAPI) to RestRunner YAML.
    # @param source [String] Path to Postman JSON or OpenAPI YAML/JSON file
    # @param output [String, nil] Optional output filename
    def import(source, output = nil)
      output ||= options[:output]
      Commands::Import.new.execute(source, output)
    end

    desc "import-env SOURCE [NAME]", "Import environment variables from Postman environment export"
    method_option :output, aliases: "-o", desc: "Output environment name (default: auto-generated)"
    # Import environment from Postman environment JSON file.
    # @param source [String] Path to Postman environment JSON file
    # @param name [String, nil] Optional output environment name
    def import_env(source, name = nil)
      name ||= options[:output]
      Commands::ImportEnv.new.execute(source, name)
    end

    desc "secret-store KEY [VALUE]", "Store a secret securely in system keychain"
    # Store a sensitive value in secure storage (Keychain, pass, or .env.local).
    # @param key [String] Secret key/name
    # @param value [String, nil] Secret value (prompted if omitted)
    def secret_store(key, value = nil)
      Commands::SecretStore.new.execute(key, value)
    end

    desc "secret-list", "List all stored secrets"
    # List all secret keys stored in keychain (values masked for security).
    def secret_list
      Commands::SecretList.new.execute
    end

    desc "secret-retrieve KEY", "Retrieve a secret from keychain"
    # Look up and display a secret (masked to prevent shoulder surfing).
    # @param key [String] Secret key to retrieve
    def secret_retrieve(key)
      Commands::SecretRetrieve.new.execute(key)
    end
  end
end