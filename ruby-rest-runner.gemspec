# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name          = "ruby-rest-runner"
  s.version       = "1.0.0"
  s.authors       = ["Ruby REST Runner Contributors"]
  s.email         = ["dev@ruby-rest-runner.local"]
  s.summary       = "High-performance Postman alternative with async Fiber execution"
  s.description   = <<~DESC
    A feature-rich REST API testing tool built in Ruby with Fiber-based async execution,
    Postman/OpenAPI support, multi-environment management, and secure secret handling.
  DESC
  s.homepage      = "https://github.com/peckolai/ruby-rest-runner"
  s.license       = "MIT"

  # Executables
  s.executables   = ["rest-run"]
  s.files         = Dir.glob("lib/**/*") + Dir.glob("bin/**/*") + Dir.glob("config/**/*") + 
                    %w[Gemfile README.md QUICK_START.md SECURITY.md LICENSE .yardopts]

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
