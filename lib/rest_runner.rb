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
    desc "exec PATH", "Execute a REST collection file (YAML format)"
    method_option :env, aliases: "-e", desc: "Path to environment variables file"
    method_option :verbose, type: :boolean, default: false, desc: "Show detailed output"
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
  end
end