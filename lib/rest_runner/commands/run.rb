module RestRunner
  module Commands
    # Execute a collection file and display results.
    # @see RestRunner::CLI#run
    class Run
      # Initialize with CLI options.
      # @param options [Hash] Thor options (:env, :verbose, etc.)
      def initialize(options = {})
        @options = options
      end

      # Execute the collection file.
      # @param path [String] Path to YAML collection file
      # @return [void]
      def execute(path)
        collection = CollectionParser.load(path)

        # Load environment if specified
        env_manager = EnvironmentManager.new(@options[:env]) if @options[:env]
        env_vars = env_manager&.variables || {}

        # Resolve variables with environment context
        VariableResolver.resolve!(collection, env_vars)

        overall_success = true
        results = []

        puts "\n"
        puts set_color("Running: #{collection[:name]}", :bold)
        
        # Display active environment if set
        if env_manager&.current_env
          puts set_color("Environment: #{env_manager.current_env}", :cyan)
        end
        
        puts set_color("=" * 60, :cyan)

        # Use progress bar if we have many tests
        if collection[:tests].length > 1 && !@options[:verbose]
          progress_bar = TTY::ProgressBar.new(
            "[:bar] :current/:total tests complete",
            total: collection[:tests].length,
            bar_format: :block
          )
        end

        collection[:tests].each do |test_spec|
          executor = Executor.new(test_spec, debug: @options[:debug])
          result = executor.run_test

          if result[:success]
            progress_bar&.advance
          else
            overall_success = false
            progress_bar&.advance
          end

          results << result
        end

        progress_bar&.finish if progress_bar

        # Display results table
        puts "\n"
        header = ["Test Name", "Status", "Code", "Latency"]
        rows = results.map do |r|
          status_color = r[:success] ? :green : :red
          [
            r[:name],
            colorize_status(r[:success]),
            r[:status],
            "#{r[:latency_ms]}ms"
          ]
        end

        table = TTY::Table.new(header, rows)
        puts table.render(:ascii, padding: [0, 2])

        # Summary
        passed = results.count { |r| r[:success] }
        total = results.length
        summary_color = overall_success ? :green : :red

        puts "\n"
        puts set_color("#{passed}/#{total} tests passed", summary_color)
        puts set_color("=" * 60, :cyan)

        exit(overall_success ? 0 : 1)
      end

      private

      # Colorize the status text for terminal display.
      # @param success [Boolean] Whether test passed
      # @return [String] Colored status string
      def colorize_status(success)
        status_text = success ? "PASS" : "FAIL"
        color = success ? :green : :red
        set_color(status_text, color)
      end

      # Convenience method to set color in output (Thor-style).
      # @param text [String] Text to color
      # @param color [Symbol] Color name (:green, :red, :cyan, :bold)
      # @return [String] ANSI-colored text
      def set_color(text, color)
        case color
        when :green
          "\e[32m#{text}\e[0m"
        when :red
          "\e[31m#{text}\e[0m"
        when :cyan
          "\e[36m#{text}\e[0m"
        when :bold
          "\e[1m#{text}\e[0m"
        else
          text
        end
      end
    end
  end
end
