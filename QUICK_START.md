# Quick Start Guide: Ruby REST Runner

Get up and running with REST Runner in 5 minutes!

## 🚀 Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/ruby-rest-runner.git
cd ruby-rest-runner

# Install dependencies
bundle install

# Verify installation
./bin/rest-run help
```

## 📝 Your First Collection

Create a file `my_api_tests.yml`:

```yaml
name: My First API Tests
tests:
  - name: Get JSON placeholder post
    endpoint: https://jsonplaceholder.typicode.com/posts/1
    method: GET
    assertions:
      status: 200
      body_contains: userId

  - name: Create a post
    endpoint: https://jsonplaceholder.typicode.com/posts
    method: POST
    headers:
      Content-Type: application/json
    body:
      title: "Hello World"
      body: "This is my first REST test"
      userId: 1
    assertions:
      status: 201
```

## 🏃 Run Your First Test

```bash
# Execute the collection
./bin/rest-run exec my_api_tests.yml

# You should see:
# ✓ Get JSON placeholder post (234ms)
# ✓ Create a post (456ms)
```

## 🔧 Environment Variables

Create `config/envs/development.yml`:

```yaml
base_url: https://jsonplaceholder.typicode.com
api_key: your_test_api_key_here
```

Update your collection to use variables:

```yaml
name: My API Tests
tests:
  - name: Get post
    endpoint: ${base_url}/posts/1
    method: GET
    headers:
      Authorization: Bearer ${api_key}
    assertions:
      status: 200
```

Run with the environment:

```bash
./bin/rest-run exec my_api_tests.yml -e development
```

## 🔐 Manage Secrets

Store sensitive API keys securely:

```bash
# Store a secret
./bin/rest-run secret-store my_api_key "sk_live_abc123xyz"

# List stored secrets
./bin/rest-run secret-list

# Retrieve a secret (masked output)
./bin/rest-run secret-retrieve my_api_key
```

Use secrets in environment files:

```yaml
# config/envs/production.yml
base_url: https://api.example.com
api_key: ${MY_API_KEY}  # Will be injected from stored secret
```

## 📦 Import Collections

### From Postman

Export your Postman collection and import it:

```bash
./bin/rest-run import my_postman_collection.json -o imported_collection.yml

# Run imported collection
./bin/rest-run exec imported_collection.yml
```

### From OpenAPI

Convert OpenAPI specs to runnable collections:

```bash
./bin/rest-run import openapi.yaml -o api_tests.yml
```

## 🌍 Manage Environments

List available environments:

```bash
./bin/rest-run env-list
```

View an environment:

```bash
./bin/rest-run env-use production
```

Set a variable:

```bash
./bin/rest-run env-set my_base_url "https://api.example.com"
```

## 📊 Advanced Usage

### Multi-Environment Setup

Create multiple environment files:

```bash
# Development
echo "base_url: http://localhost:3000" > config/envs/dev.yml

# Staging  
echo "base_url: https://staging.example.com" > config/envs/staging.yml

# Production
echo "base_url: https://api.example.com" > config/envs/prod.yml
```

Run tests against each:

```bash
./bin/rest-run exec collection.yml -e dev
./bin/rest-run exec collection.yml -e staging
./bin/rest-run exec collection.yml -e prod
```

### Variable Substitution

Use variables anywhere in your collection:

```yaml
tests:
  - name: Dynamic endpoint
    endpoint: ${base_url}/api/users/${user_id}
    method: GET
    headers:
      Authorization: Bearer ${api_token}
      X-Custom-Header: ${custom_value}
    assertions:
      status: 200
```

### Response Assertions

Verify multiple aspects of responses:

```yaml
tests:
  - name: Verify API response
    endpoint: ${base_url}/api/status
    method: GET
    assertions:
      status: 200                    # Check HTTP status
      body_contains: "operational"   # Check response body
      max_latency_ms: 500           # Performance check
```

## 📚 Documentation

View full documentation:

```bash
# Generate YARD docs
bundle exec yard doc

# Open in browser
open doc/index.html
```

View README:

```bash
cat README.md
```

## 🧪 Run Tests

Verify the installation with the test suite:

```bash
bundle exec rspec spec/

# Run specific test file
bundle exec rspec spec/rest_runner/executor_spec.rb

# Show slow tests
bundle exec rspec spec/ --profile
```

## 🎯 Common Tasks

### Create a reusable collection template

`templates/api_test.yml`:

```yaml
name: Template Collection
tests:
  - name: Health check
    endpoint: ${base_url}/health
    method: GET
    assertions:
      status: 200

  - name: Get users
    endpoint: ${base_url}/api/users
    method: GET
    headers:
      Authorization: Bearer ${api_token}
    assertions:
      status: 200
      body_contains: "id"
```

Copy and customize:

```bash
cp templates/api_test.yml my_tests.yml
./bin/rest-run exec my_tests.yml -e development
```

### Organize by API version

```
collections/
├── v1/
│   ├── auth.yml
│   ├── users.yml
│   └── posts.yml
└── v2/
    ├── auth.yml
    ├── users.yml
    └── posts.yml
```

List collections:

```bash
./bin/rest-run collections-list
```

### Performance monitoring

Track response times:

```bash
./bin/rest-run exec collection.yml --verbose
```

Use the built-in benchmark:

```bash
ruby benchmark_async_vs_sync.rb
```

## ❓ Troubleshooting

### Collection not found

```bash
# Make sure your collection file exists
ls -la my_collection.yml

# Check the exact path
./bin/rest-run exec ./collections/my_collection.yml
```

### Environment not loading

```bash
# Verify env file exists
ls -la config/envs/development.yml

# Check env variable syntax (use ${VAR_NAME})
grep '\${' collections/*.yml
```

### Secret not retrieving

```bash
# List stored secrets
./bin/rest-run secret-list

# Make sure secret key matches
./bin/rest-run secret-retrieve my_secret
```

## 🆘 Getting Help

- 📖 Full documentation: `README.md`
- 🔍 API docs: `open doc/index.html`
- 🤔 FAQ: See GitHub Issues
- 💬 Contributing: Submit a PR!

## 📋 Next Steps

1. ✅ Run your first collection
2. ✅ Set up environments  
3. ✅ Store secrets securely
4. ✅ Import Postman collections
5. ✅ Automate with CI/CD (coming soon!)

Happy testing! 🎉
