# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name          = "ruby-rest-runner"
  s.version       = "0.1.0"
  s.authors       = ["Ruby REST Runner Contributors"]
  s.email         = ["dev@ruby-rest-runner.local"]
  s.summary       = "High-performance REST collection runner for the terminal"
  s.description   = "A Postman-like CLI tool for executing and validating REST API collections with async/Fiber-based concurrency"
  s.homepage      = "https://github.com/username/ruby-rest-runner"
  s.license       = "MIT"

  # Executables
  s.executables   = ["rest-run"]
  s.files         = Dir.glob("lib/**/*") + Dir.glob("bin/**/*") + Dir.glob("config/**/*") + 
                    ["Gemfile", "README.md", "LICENSE"]

  # Ruby version
  s.required_ruby_version = ">= 3.4.0"

  # Core dependencies (from Gemfile)
  s.add_runtime_dependency "thor", "~> 1.5"
  s.add_runtime_dependency "faraday", "~> 2.14"
  s.add_runtime_dependency "async", "~> 2.39"
  s.add_runtime_dependency "async-http", "~> 0.94"
  s.add_runtime_dependency "tty-table", "~> 0.12"
  s.add_runtime_dependency "tty-prompt", "~> 0.23"
  s.add_runtime_dependency "tty-progressbar", "~> 0.18"
  s.add_runtime_dependency "tty-color", "~> 0.6"
  s.add_runtime_dependency "zeitwerk", "~> 2.7"
  s.add_runtime_dependency "dry-validation", "~> 1.11"
  s.add_runtime_dependency "benchmark"

  # Development dependencies
  s.add_development_dependency "rspec", "~> 3.13"
  s.add_development_dependency "aruba", "~> 1.1"
  s.add_development_dependency "pry"
  s.add_development_dependency "byebug"
end
