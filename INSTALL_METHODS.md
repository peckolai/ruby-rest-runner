# Installation Methods Reference

This guide explains all available installation methods for ruby-rest-runner and when to use each one.

## Quick Comparison

| Method | Platform | Requires Ruby | Package Size | Setup Time | Use Case |
|--------|----------|---------------|--------------|------------|----------|
| **Direct** | Any | ✅ Yes (3.4+) | N/A | ~2 min | Developers, CI/CD |
| **Docker** | Any | ❌ No | ~200 MB image | ~3 min | Containers, CI/CD, Isolation |
| **OCRA (Windows .exe)** | Windows | ❌ No | 150-200 MB | ~5 min | Windows users, Distribution |
| **TravlingRuby** | Any | ❌ No | 50 MB/platform | ~10 min | Cross-platform distribution |
| **RubyGems** | Any | ✅ Yes (3.4+) | ~5 MB gem | ~1 min | Ruby projects, Bundler |
| **Homebrew (macOS)** | macOS | ❌ No | ~50 MB | ~1 min | macOS users |

---

## Installation Methods

### 1️⃣ Direct Installation (Developers)

**Best for:** Development, CI/CD pipelines, local testing

**Requirements:**
- Ruby 3.4+
- Bundler
- Git

**Setup:**
```bash
git clone https://github.com/yourusername/ruby-rest-runner.git
cd ruby-rest-runner
bundle install
./bin/rest-run --help
```

**Pros:**
- Fastest setup time
- Access to source code
- Easy debugging

**Cons:**
- Requires Ruby installation
- Dependency management needed

---

### 2️⃣ Docker Installation (Containers & CI/CD)

**Best for:** CI/CD pipelines, containerized deployments, cloud environments

**Requirements:**
- Docker or Docker Desktop
- No Ruby installation needed

**Setup:**
```bash
docker build -t ruby-rest-runner:latest .
docker run --rm -v $(pwd)/collections:/app/collections:ro ruby-rest-runner:latest exec collections/demo.yml
```

**Or with Docker Compose:**
```bash
docker-compose up --build
docker-compose run --rm rest-runner exec collections/demo.yml
```

**Pros:**
- Isolates dependencies
- Consistent across environments
- Works in cloud platforms
- Easy scaling

**Cons:**
- Requires Docker installation
- Slightly larger footprint (~200 MB image)
- May trigger security policies

**See:** [DOCKER.md](DOCKER.md)

---

### 3️⃣ OCRA Windows Executable (Windows Users)

**Best for:** Windows-only deployment, end users, distribution

**Requirements:**
- Windows system
- Ruby 3.4+ (for building only)
- OCRA gem

**Setup:**
```bash
gem install ocra
ruby build_ocra_exe.rb
```

Creates: `dist/rest-run.exe`

**Usage:**
```cmd
rest-run.exe --help
rest-run.exe exec collections/demo.yml
```

**Pros:**
- Single executable file
- No Ruby installation needed
- Windows native feel
- Can create installers

**Cons:**
- ~150-200 MB file size
- Slow first run (5-10 seconds)
- Windows only
- May trigger antivirus

**See:** [INSTALL_OCRA.md](INSTALL_OCRA.md)

---

### 4️⃣ TravlingRuby Packages (Cross-Platform)

**Best for:** Distributing to multiple platforms, users without Ruby

**Requirements:**
- Ruby 3.4+ (for building only)
- TravlingRuby gem
- Build system (bash/make)

**Setup:**
```bash
gem install traveling-ruby
./build_traveling_ruby.sh
```

Creates:
- `dist/ruby-rest-runner-1.0.0-linux-x86_64.tar.gz`
- `dist/ruby-rest-runner-1.0.0-macos.tar.gz`
- `dist/ruby-rest-runner-1.0.0-windows.zip`

**Usage:**

Linux/macOS:
```bash
tar xzf ruby-rest-runner-1.0.0-linux-x86_64.tar.gz
cd ruby-rest-runner-1.0.0
./rest-run --help
```

Windows:
```cmd
unzip ruby-rest-runner-1.0.0-windows.zip
cd ruby-rest-runner-1.0.0
rest-run.bat --help
```

**Pros:**
- Smaller files (~50 MB each)
- Works on any system
- No Ruby required
- Fast startup

**Cons:**
- Per-platform build needed
- Slightly larger than Docker
- Complex build process

**See:** [INSTALL_TRAVELING_RUBY.md](INSTALL_TRAVELING_RUBY.md)

---

### 5️⃣ RubyGems Package (Ruby Projects)

**Best for:** Ruby projects, Bundler dependency

**Requirements:**
- Ruby 3.4+
- Bundler

**Installation:**
```bash
# Add to Gemfile
gem 'ruby-rest-runner'

# Install
bundle install

# Use in code
require 'rest_runner'
runner = RestRunner::Executor.new(collection)
runner.execute
```

**Or install globally:**
```bash
gem install ruby-rest-runner
rest-run --help
```

**Pros:**
- Lightweight (~5 MB)
- Easy integration
- Dependency management
- Version pinning

**Cons:**
- Requires Ruby
- Only for Ruby projects
- Not yet published

**Status:** Gem ready but not yet published to RubyGems.org

---

### 6️⃣ Homebrew (macOS)

**Best for:** macOS users, simple installation

**Requirements:**
- macOS with Homebrew

**Installation:**
```bash
brew install yourusername/rest-runner/ruby-rest-runner
rest-run --help
```

**Pros:**
- Familiar for macOS users
- One command install
- Auto-updates available
- No Ruby awareness needed

**Cons:**
- macOS only
- Need to publish tap
- Manual homebrew setup required

**Status:** Not yet available (future enhancement)

---

## Decision Tree

```
Do you want to use this in a project?
├─ Yes, Ruby project
│  └─ Use RubyGems (option 5)
│
└─ No, standalone tool

   Which platform?
   ├─ Linux/macOS/Windows
   │  ├─ Need cross-platform distribution?
   │  │  ├─ Yes → Use TravlingRuby (option 4)
   │  │  └─ No → Use Docker (option 2)
   │  │
   │  └─ Have Docker available?
   │     ├─ Yes → Use Docker (option 2)
   │     └─ No → Use TravlingRuby (option 4)
   │
   └─ Windows only
      ├─ End users → Use OCRA (option 3)
      └─ Developers → Use Direct (option 1)

   Are you developing?
   └─ Yes → Use Direct (option 1)
```

---

## Recommendations by Use Case

### Developers
```
Primary: Direct Installation (Option 1)
Fallback: Docker (Option 2)
```

### End Users (Windows)
```
Primary: OCRA Executable (Option 3)
Fallback: Docker Desktop (Option 2)
```

### End Users (macOS)
```
Primary: TravlingRuby (Option 4)
Secondary: Homebrew (Option 6) - when available
Fallback: Docker (Option 2)
```

### End Users (Linux)
```
Primary: TravlingRuby (Option 4)
Secondary: Distribution packages (future)
Fallback: Docker (Option 2)
```

### CI/CD Pipelines
```
Primary: Docker (Option 2)
Secondary: Direct (Option 1)
```

### Cloud Deployment
```
Primary: Docker (Option 2)
Secondary: TravlingRuby (Option 4)
```

### Enterprise Distribution
```
Primary: OCRA with Installer (Option 3 + NSIS)
Secondary: TravlingRuby (Option 4)
Fallback: Docker (Option 2)
```

---

## Comparison Matrix

### Build Complexity
```
Direct           ████░░░░░░ (1/10) - Just clone and bundle
RubyGems         ███░░░░░░░ (2/10) - Build, publish
Docker           ████░░░░░░ (2/10) - One build command
TravlingRuby     ████████░░ (7/10) - Multi-platform complex
OCRA             ███████░░░ (6/10) - Windows specific
Homebrew         █████████░ (9/10) - Tap setup required
```

### Distribution Size
```
RubyGems         █░░░░░░░░░ (5 MB)
Docker           ███████░░░ (200 MB image)
TravlingRuby     ████░░░░░░ (50 MB per platform)
OCRA             █████████░ (150-200 MB)
Direct           █░░░░░░░░░ (5 MB + Ruby)
```

### First-Time Setup (User)
```
Direct           ████░░░░░░ (2 min + Ruby)
Docker           ██████░░░░ (3-5 min)
TravlingRuby     ██░░░░░░░░ (30 seconds)
OCRA             ███░░░░░░░ (extraction time)
RubyGems         ██░░░░░░░░ (1 minute)
Homebrew         █░░░░░░░░░ (10 seconds)
```

### Cross-Platform Support
```
Docker           ██████████ (All platforms)
TravlingRuby     ██████████ (All platforms)
Direct           ████████░░ (Any OS with Ruby)
RubyGems         ████████░░ (Any OS with Ruby)
OCRA             ██░░░░░░░░ (Windows only)
Homebrew         ██░░░░░░░░ (macOS only)
```

---

## Publishing Checklist

- [ ] Test all installation methods locally
- [ ] Document each method thoroughly
- [ ] Create build scripts and automation
- [ ] Test on target platforms (Windows, macOS, Linux)
- [ ] Create GitHub releases with binaries
- [ ] Setup CI/CD to auto-build and publish
- [ ] Document troubleshooting for each method
- [ ] Get community feedback

---

## Next Steps

1. **Choose Your Primary Distribution Method**
   - Docker for cloud/CI/CD
   - OCRA for Windows users
   - TravlingRuby for cross-platform

2. **Set Up GitHub Releases**
   - Attach built artifacts to releases
   - Create release notes for each version

3. **Configure CI/CD**
   - Automate builds on tag push
   - Upload artifacts to GitHub

4. **Create Quick-Start Scripts**
   - Bash/batch installers
   - One-line setup commands

5. **Monitor Usage**
   - Track download stats
   - Collect user feedback
   - Iterate on installation experience

---

## Support & Troubleshooting

Each installation method has detailed troubleshooting:

- **Direct:** See development guides
- **Docker:** [DOCKER.md](DOCKER.md)
- **OCRA:** [INSTALL_OCRA.md](INSTALL_OCRA.md)
- **TravlingRuby:** [INSTALL_TRAVELING_RUBY.md](INSTALL_TRAVELING_RUBY.md)

---

## Version Matrix

Track which features work with each installation method:

| Feature | Direct | Docker | OCRA | TravlingRuby | RubyGems |
|---------|--------|--------|------|--------------|----------|
| Native CLI | ✅ | ✅ | ✅ | ✅ | ✅ |
| Docker | ✅ | N/A | ❌ | ❌ | ✅ |
| GUI (future) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Library API | ✅ | ❌ | ❌ | ❌ | ✅ |
| Debugger | ✅ | ✅ | ❌ | ❌ | ✅ |

---

## Resources

- [DOCKER.md](DOCKER.md) - Docker detailed guide
- [INSTALL_OCRA.md](INSTALL_OCRA.md) - Windows .exe building
- [INSTALL_TRAVELING_RUBY.md](INSTALL_TRAVELING_RUBY.md) - Cross-platform packages
- [QUICK_START.md](QUICK_START.md) - 5-minute setup
- [SECURITY.md](SECURITY.md) - Security best practices
