# Security & Secrets Management

## Overview

`ruby-rest-runner` provides secure secret management for handling sensitive credentials (API keys, tokens, passwords) with multiple storage backends.

---

## Storage Backends

### macOS Keychain (Recommended for macOS)
- **Availability:** macOS only
- **Security:** System-level encryption, passwords never written to disk
- **Access:** Automatic via `security` command
- **Auto-detected:** Yes (if running on macOS)

```bash
# Secrets stored in macOS Keychain
rest-run secret-store api_key sk_live_12345
rest-run secret-list
rest-run secret-retrieve api_key
```

### pass (Recommended for Linux)
- **Availability:** Linux with `pass` utility installed
- **Security:** GPG-encrypted files in `~/.password-store/`
- **Installation:** `sudo apt-get install pass` (Debian/Ubuntu)
- **Setup:** Initialize with `pass init <your-gpg-id>`
- **Auto-detected:** Yes (if `pass` command available)

```bash
# Secrets stored in pass
rest-run secret-store api_key sk_live_12345
rest-run secret-list
rest-run secret-retrieve api_key
```

### Local .env.local (Fallback)
- **Availability:** Any OS
- **Security:** File-based storage (add to .gitignore!)
- **Warning:** Not encrypted; use only for non-sensitive data or development

```bash
# Add to .gitignore to prevent accidental commits
echo ".env.local" >> .gitignore

# Secrets stored locally
rest-run secret-store api_key sk_live_12345
```

---

## Commands

### Store a Secret

```bash
# Interactive (prompts for value)
rest-run secret-store api_key

# Direct (value in command)
rest-run secret-store api_key my_secret_value
```

### List Secrets

```bash
# List all stored secret keys
rest-run secret-list

# Output:
# Stored Secrets (macOS Keychain)
# ────────────────────────────────
#   • api_key
#   • db_password
#   • oauth_token
```

### Retrieve a Secret

```bash
# Retrieve and display a secret (masked to prevent shoulder surfing)
rest-run secret-retrieve api_key

# Output:
# Secret: api_key
# ────────────────────────────────
#   Value: sk_l****************************
```

---

## Using Secrets in Collections

### Reference Secrets in Environment Files

```yaml
# config/envs/production.yml
base_url: https://api.example.com
api_key: ${API_KEY}  # Will be resolved from secret store
db_password: ${DB_PASSWORD}
```

### Run Collection with Environment

```bash
# Set the secret first
rest-run secret-store API_KEY sk_live_1234567890

# Create environment file referencing the secret
echo "api_key: \${API_KEY}" > config/envs/production.yml

# Run collection (secrets auto-resolved)
rest-run exec -e production collections/api_tests.yml
```

---

## Best Practices

### ✅ DO

- **Store all production secrets** in macOS Keychain or pass (not .env.local)
- **Use environment variables** in collections instead of hardcoded values
- **Rotate secrets regularly**, especially API keys and tokens
- **Use unique secrets per environment** (dev, staging, production)
- **Add .env.local to .gitignore** if using file-based storage
- **Audit secret access** if using pass (GPG logs)

### ❌ DON'T

- **Commit secrets to git** (even accidentally)
- **Store production secrets** in .env.local
- **Log secrets** to console (use masked display)
- **Share credentials** via email or Slack
- **Use the same secret** across multiple environments
- **Hardcode secrets** in collection YAML files

---

## Setup Guides

### macOS Keychain (Pre-configured)

No setup needed! Secrets are automatically stored in your system Keychain.

```bash
rest-run secret-store DATABASE_PASSWORD prod_password_123
# ✓ Secret 'DATABASE_PASSWORD' stored successfully
#   Backend: macOS Keychain
```

### Linux: Setting up `pass`

#### Installation
```bash
# Debian/Ubuntu
sudo apt-get install pass

# Fedora/RHEL
sudo dnf install pass

# macOS (if not using native Keychain)
brew install pass

# Arch
sudo pacman -S pass
```

#### Initialize GPG

```bash
# List available GPG keys
gpg --list-keys

# If no keys exist, create one
gpg --gen-key
# Follow prompts to create a key

# Get your key ID
gpg --list-keys --keyid-format LONG
# Example output: rsa2048 ABCD1234EFGH5678
```

#### Initialize pass

```bash
# Initialize password store with your GPG key
pass init ABCD1234EFGH5678

# Verify setup
pass show  # Should list an empty password store
```

#### Usage

```bash
rest-run secret-store API_KEY sk_live_123456

# Secrets are stored at:
# ~/.password-store/ruby-rest-runner/API_KEY.gpg
```

### Local .env.local (Development Only)

No setup needed, but ensure it's in .gitignore:

```bash
echo ".env.local" >> .gitignore

rest-run secret-store DEV_API_KEY dev_key_123456
```

---

## Troubleshooting

### "Permission denied" on macOS Keychain

```
❌ Error: Permission denied when storing secret
```

**Solution:** Allow the terminal app to access Keychain.
1. Open Keychain Access (Cmd+Space → "Keychain Access")
2. Find your Keychain entry under "Local Items"
3. Double-click and set "When considering whether to allow access..."
   to "Always Allow"

### "pass: No such file or directory" on Linux

```
❌ Error: pass command not found
```

**Solution:** Install and initialize pass (see setup guide above).

### Secrets stored locally but I want Keychain

```
# Check current backend
rest-run secret-list
# Output: Stored Secrets (Local .env.local)
```

**Solution:** Install pass or macOS will auto-switch when available.

---

## Security Considerations

### Secret Rotation

Rotate sensitive secrets regularly:

```bash
# Old secret
rest-run secret-retrieve api_key_old

# Generate new secret in your API provider dashboard
# Store the new secret
rest-run secret-store api_key_new <new_key>

# Update environment files to use api_key_new
# Remove old secret when confident
rm ~/.password-store/ruby-rest-runner/api_key_old.gpg
```

### Environment-Specific Secrets

Keep secrets segregated by environment:

```bash
# Production secrets
rest-run secret-store prod_api_key sk_live_prod_123
rest-run secret-store prod_db_password prod_pass_xyz

# Development secrets
rest-run secret-store dev_api_key sk_test_dev_456
rest-run secret-store dev_db_password dev_pass_abc
```

### Audit Trail

For `pass`-based storage, you can audit access:

```bash
# View GPG logs
gpg --list-packets ~/.password-store/ruby-rest-runner/api_key.gpg

# Backup secrets (encrypted)
cp -r ~/.password-store ~/dropbox/password-store-backup
```

---

## Integration with CI/CD

### GitHub Actions

```yaml
name: Run REST Tests

on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.4
      
      - name: Store secrets as env vars
        run: |
          echo "API_KEY=${{ secrets.PROD_API_KEY }}" >> /tmp/secrets.env
          echo "DB_PASSWORD=${{ secrets.PROD_DB_PASSWORD }}" >> /tmp/secrets.env
      
      - name: Run REST tests
        run: |
          source /tmp/secrets.env
          bundle exec rest-run exec -e production collections/api_tests.yml
```

### GitLab CI

```yaml
run_tests:
  image: ruby:3.4
  script:
    - export API_KEY=$PROD_API_KEY
    - export DB_PASSWORD=$PROD_DB_PASSWORD
    - bundle exec rest-run exec -e production collections/api_tests.yml
  variables:
    PROD_API_KEY: $CI_API_V4_TOKEN
    PROD_DB_PASSWORD: $PROD_DB_PASSWORD
```

---

## Further Reading

- [1Password CLI](https://1password.com/developers/) - Enterprise password management
- [macOS Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
- [pass - The Standard Unix Password Manager](https://www.passwordstore.org/)
- [OWASP: Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
