# Installation Quick Start

Choose your installation method below:

## 👨‍💻 For Developers
```bash
git clone https://github.com/yourusername/ruby-rest-runner.git
cd ruby-rest-runner
bundle install
./bin/rest-run --help
```
See: [Direct Installation](INSTALL_METHODS.md#1️⃣-direct-installation-developers)

## 🐳 For Docker Users
```bash
docker build -t ruby-rest-runner:latest .
docker run --rm -v $(pwd)/collections:/app/collections:ro ruby-rest-runner:latest exec collections/demo.yml
```
See: [Docker Installation](INSTALL_METHODS.md#2️⃣-docker-installation-containers--cicd)

## 🪟 For Windows Users (No Ruby needed)
```bash
gem install ocra
ruby build_ocra_exe.rb
./dist/rest-run.exe --help
```
See: [OCRA Windows Executable](INSTALL_OCRA.md)

## 📦 For Cross-Platform Distribution
```bash
./build_traveling_ruby.sh
# Creates: dist/ruby-rest-runner-1.0.0-*.{tar.gz,zip}
```
See: [TravlingRuby Packages](INSTALL_TRAVELING_RUBY.md)

## 🔧 Using Make
```bash
make ocra-build              # Build Windows .exe
make traveling-ruby-build    # Build cross-platform packages
make docker-build            # Build Docker image
make test                    # Run tests
make clean                   # Clean build artifacts
```

---

## Installation Methods Matrix

| Method | Platform | Ruby? | Size | Setup Time | Best For |
|--------|----------|-------|------|-----------|----------|
| Direct | Any | ✓ | N/A | 2 min | Developers |
| Docker | Any | ✗ | 200M | 3 min | CI/CD, Containers |
| OCRA | Windows | ✗* | 150M | 5 min | Windows Users |
| TravlingRuby | Any | ✗ | 50M | 30s | Distribution |

*Ruby only needed to build, not to run

---

## Full Documentation

- **[INSTALL_METHODS.md](INSTALL_METHODS.md)** - Complete reference guide (decision tree, comparisons, recommendations)
- **[INSTALL_OCRA.md](INSTALL_OCRA.md)** - Windows .exe building with NSIS installer
- **[INSTALL_TRAVELING_RUBY.md](INSTALL_TRAVELING_RUBY.md)** - Cross-platform packages
- **[DOCKER.md](DOCKER.md)** - Docker and Docker Compose
- **[QUICK_START.md](QUICK_START.md)** - 5-minute setup guide

---

## Prerequisites by Method

### Direct Install
- ✓ Ruby 3.4 or higher
- ✓ Bundler
- ✓ Git

### Docker
- ✓ Docker Desktop or Docker Engine

### OCRA Windows .exe
- ✓ Ruby 3.4+ (to build only)
- ✓ OCRA gem: `gem install ocra`
- ✓ Windows system

### TravlingRuby
- ✓ Ruby 3.4+ (to build only)
- ✓ TravlingRuby gem: `gem install traveling-ruby`
- ✓ bash/Unix tools
- ✓ curl

---

## Need Help?

1. Check [INSTALL_METHODS.md](INSTALL_METHODS.md) for your use case
2. See specific guide for your method
3. Troubleshooting section in each guide
4. Open an issue on GitHub

---

**Last Updated:** 2026-04-12  
**Version:** 1.0.0+
