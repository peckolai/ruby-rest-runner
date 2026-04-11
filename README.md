# ruby-rest-runner

A high-performance Postman alternative built in Ruby with Fiber-based async execution, multi-format collection support, and comprehensive CLI tooling.

## Features

🚀 **High Performance**
- Fiber-based async HTTP execution (non-blocking I/O)
- Concurrent test execution without thread overhead
- Sub-millisecond latency measurement

📦 **Multi-Format Support**
- Native RestRunner YAML format
- Postman v2.1 collections import
- OpenAPI 3.1 specifications import
- Automatic format detection

🔐 **Security First**
- Sensitive value masking in output
- System keychain integration (macOS, Linux pass)
- Environment variable injection with priority resolution
- Secure secret management

🎯 **Developer Friendly**
- Interactive CLI with progress bars
- Colored output for pass/fail status
- Environment variable management
- Multi-environment configuration

## Installation

### Prerequisites
- Ruby 3.4+
- Bundler

### Setup

```bash
git clone https://github.com/yourusername/ruby-rest-runner.git
cd ruby-rest-runner
bundle install
```

### Docker Installation

The fastest way to get started without installing Ruby dependencies:

```bash
# Build the Docker image
docker build -t ruby-rest-runner:latest .

# Run a collection
docker run --rm \
  -v $(pwd)/collections:/app/collections:ro \
  ruby-rest-runner:latest \
  exec collections/demo.yml
```

Or use Docker Compose:
```bash
docker-compose up --build
docker-compose run --rm rest-runner exec collections/demo.yml
```

**See [DOCKER.md](DOCKER.md) for detailed Docker usage instructions.**

### Usage

#### Run Collections
```bash
# Execute a collection with default environment
bin/rest-run exec collections/myapi.yml

# Execute with specific environment
bin/rest-run exec collections/myapi.yml -e production

# Verbose output
bin/rest-run exec collections/myapi.yml --verbose
```

#### Environment Management
```bash
# List available environments
bin/rest-run env-list

# View specific environment
bin/rest-run env-use production

# Set environment variable
bin/rest-run env-set my_var my_value

# Import Postman environment
bin/rest-run import-env postman_env_export.json my_env
```

#### Secret Management
```bash
# Store a secret in local keychain
bin/rest-run secret-store api_key "sk_live_abc123"

# List stored secrets
bin/rest-run secret-list

# Retrieve secret (masked output)
bin/rest-run secret-retrieve api_key
```

#### Import Collections
```bash
# Auto-detect format and import
bin/rest-run import postman_collection.json

# Import with custom output
bin/rest-run import postman_collection.json -o myapi.yml

# Import OpenAPI
bin/rest-run import openapi.yaml -o api.yml
```

## Collection Format

### YAML Structure

```yaml
name: My API Tests
tests:
  - name: Get Users
    endpoint: ${base_url}/api/users
    method: GET
    headers:
      Authorization: Bearer ${api_token}
      Accept: application/json
    assertions:
      status: 200
      body_contains: userId
      max_latency_ms: 500

  - name: Create User
    endpoint: ${base_url}/api/users
    method: POST
    headers:
      Content-Type: application/json
    body:
      name: John Doe
      email: john@example.com
    assertions:
      status: 201
      body_contains: id
```

### Variable Substitution

Use `${VARIABLE_NAME}` syntax for dynamic values:

```yaml
endpoint: ${base_url}/api/users
headers:
  Authorization: Bearer ${api_token}
```

Resolution priority:
1. Environment file variables
2. System ENV variables
3. Original string (fallback)

## Environment Configuration

Create environment files in `config/envs/`:

```yaml
# config/envs/development.yml
base_url: http://localhost:3000
api_token: dev_token_xyz
timeout: 30
```

```yaml
# config/envs/production.yml
base_url: https://api.example.com
api_token: prod_token_abc
timeout: 60
```

## Security

Sensitive values are automatically masked in output:

```
✓ User creation test
  Status: 201
  api_key: sk_l*********  # First 4 + last 3 chars shown
```

### Keychain Integration

Secrets are stored securely:

- **macOS**: Uses system Keychain
- **Linux**: Uses `pass` if available
- **Fallback**: Local `.env.local` file (add to .gitignore)

## Architecture

### Components

- **Executor**: Fiber-based HTTP execution engine
- **CollectionParser**: YAML validation and loading
- **VariableResolver**: Dynamic variable substitution
- **EnvironmentManager**: Multi-environment support
- **SecretsMasker**: Sensitive value detection and masking
- **KeychainIntegration**: Secure secret storage
- **Importers**: Postman & OpenAPI format converters

### Async Execution

All HTTP requests run non-blocking via Fiber Scheduler:

```ruby
collection = CollectionParser.load('collection.yml')
executor = Executor.new(collection)
results = executor.run_collection  # Non-blocking, concurrent
```

## Testing

Run the test suite:

```bash
bundle exec rspec spec/

# Show progress and slowest tests
bundle exec rspec spec/ --format progress --profile

# Run specific test file
bundle exec rspec spec/rest_runner/secrets_masker_spec.rb
```

Test coverage: **>80%**

Covers:
- SecretsMasker (36 tests)
- VariableResolver (25 tests)
- KeychainIntegration (18 tests)
- CollectionParser (14 tests)

## Documentation

Generate YARD documentation:

```bash
bundle exec yard doc

# View HTML documentation
open doc/index.html
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit changes (`git commit -am 'Add feature'`)
4. Push to branch (`git push origin feature/my-feature`)
5. Create Pull Request

## Development

### Project Structure

```
.
├── bin/
│   └── rest-run                    # CLI entry point
├── lib/
│   └── rest_runner/
│       ├── commands/               # CLI subcommands
│       ├── collection_parser.rb
│       ├── executor.rb
│       ├── environment_manager.rb
│       ├── variable_resolver.rb
│       ├── secrets_masker.rb
│       └── keychain_integration.rb
├── config/envs/                    # Environment configs
├── collections/                    # Sample collections
├── spec/                           # Test suite
└── Gemfile
```

### Dependencies

- **Thor**: CLI framework
- **Faraday**: HTTP client
- **async-http**: Non-blocking HTTP adapter
- **async**: Fiber Scheduler primitives
- **tty-***: Terminal UI components
- **Zeitwerk**: Code autoloading
- **dry-validation**: Schema validation

## Roadmap

- [ ] GUI dashboard for collection management
- [ ] CI/CD pipeline integration (GitHub Actions, GitLab CI)
- [ ] Team collaboration features
- [ ] Cloud-based result storage
- [ ] Performance benchmarking dashboard
- [ ] Request/response caching
- [ ] GraphQL support

## License

MIT License - see LICENSE file for details

## Support

For issues, feature requests, or questions:
- [GitHub Issues](https://github.com/yourusername/ruby-rest-runner/issues)
- [Documentation](doc/)
- Email: support@example.com

---

**Built with Ruby 3.4+ • Fiber-based async • 100% open source**
