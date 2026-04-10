require "thor"
require "zeitwerk"
require "tty-table"

# Setup autoloading so we don't have to manually 'require' every file
loader = Zeitwerk::Loader.for_gem
loader.setup

module RestRunner
  class CLI < Thor
    desc "run PATH", "Execute a REST collection file (YAML)"
    method_option :env, aliases: "-e", desc: "Path to environment variables file"
    method_option :verbose, type: :boolean, default: false
    
   # Inside lib/rest_runner.rb
    def exec(path)
      collection = CollectionParser.load(path)
      VariableResolver.resolve!(collection)

      overall_success = true
      results = []

      say "\nRunning: #{collection[:name]}", :bold
      say "=" * 40

      collection[:tests].each do |test_spec|
        print "TEST: #{test_spec[:name]} ... "
        
        executor = Executor.new(test_spec)
        result = executor.run_test
        
        if result[:success]
          say "PASS", :green
        else
          say "FAIL", :red
          overall_success = false
        end

        results << result
      end

      say "\n"
      header = ["Test Name", "Status", "Code", "Latency"]
      rows = results.map do |r|
        status_color = r[:success] ? :green : :red
        [
          r[:name],
          set_color(r[:success] ? "PASS" : "FAIL", status_color),
          r[:status],
          "#{r[:latency_ms]}ms"
        ]
      end

      table = TTY::Table.new(header, rows)
      puts table.render(:ascii, padding: [0, 2])

      exit(overall_success ? 0 : 1)
    end
  end
end