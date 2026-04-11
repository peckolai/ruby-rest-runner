require 'yaml'

module RestRunner
  module Commands
    # List all available collection files from collections/ directory.
    class CollectionsList
      # Discover and display available collections.
      # @return [void]
      def execute
        collections_dir = File.join(Dir.pwd, "collections")

        if !Dir.exist?(collections_dir)
          puts "\n⚠️  No collections/ directory found."
          puts "\n⚠️  No collections/ directory found."
          puts "   Create one and add .yml collection files."
          return
        end

        collection_files = Dir.glob(File.join(collections_dir, "*.yml")) + 
                          Dir.glob(File.join(collections_dir, "*.yaml"))

        if collection_files.empty?
          puts "\n⚠️  No collection files found in collections/"
          puts "   Add .yml or .yaml files with REST test specifications."
          return
        end

        puts "\n"
        puts colorize_text("Available Collections", :cyan)
        puts colorize_text("-" * 60, :cyan)

        collection_files.each do |file|
          collection_name = File.basename(file, File.extname(file))
          begin
            data = YAML.load_file(file, symbolize_names: true)
            test_count = (data[:tests] || []).length
            description = data[:description] || "(no description)"
            
            puts "\n  #{colorize_text(collection_name, :green)}"
            puts "    Tests: #{test_count}"
            puts "    Desc:  #{description}"
          rescue => e
            puts "\n  #{colorize_text(collection_name, :red)} (invalid YAML: #{e.message})"
          end
        end

        puts "\n"
      end

      private

      # Helper to colorize text for terminal display.
      # @param text [String] Text to colorize
      # @param color [Symbol] Color name
      # @return [String] ANSI-colored text
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
