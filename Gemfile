# frozen_string_literal: true
gem "rouge"          # For syntax highlighting of JSON in debug output

source "https://rubygems.org"

gem "thor"           # For the CLI wrapper
gem "faraday"        # The HTTP client
gem "async-http"     # Non-blocking HTTP via Fiber Scheduler
gem "async"          # Fiber-based concurrency primitives
gem "tty-table"      # For pretty console output
gem "tty-prompt"     # For interactive user prompts
gem "tty-progressbar" # For progress indication during operations
gem "tty-color"      # To detect CI vs Interactive terminal
gem "zeitwerk"       # For elegant code loading (standard in modern Ruby)
gem "dry-validation" # For validating our YAML schema
gem "benchmark"      # Standard library support for latency measurement (needed for Ruby 3.4+)

gem 'pry'
gem 'byebug'

group :test do
  gem 'rspec', '~> 3.13'   # BDD testing framework
  gem 'rspec-its'          # Attribute testing helper
end

group :development do
  gem 'yard'               # YARD documentation generation
  gem 'kramdown'           # Markdown processor for YARD
end