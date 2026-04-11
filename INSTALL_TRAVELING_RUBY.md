# TravlingRuby Installation Guide

TravlingRuby provides pre-built Ruby binaries for Windows, macOS, and Linux, making it easy to distribute ruby-rest-runner without requiring users to install Ruby separately.

## What is TravlingRuby?

TravlingRuby is a Ruby packaging tool that bundles Ruby runtime with your application, creating a self-contained package that works on systems without Ruby installed.

## Installation Steps

### 1. Install TravlingRuby Gem

```bash
gem install traveling-ruby
```

### 2. Create a Build Package Script

Create a file named `build_traveling_ruby.sh`:

```bash
#!/bin/bash
set -e

VERSION="1.0.0"
WORK_DIR="tmp/traveling-ruby"
APP_DIR="ruby-rest-runner-${VERSION}"
DIST_DIR="dist"

# Clean previous builds
rm -rf "$WORK_DIR" "$DIST_DIR"
mkdir -p "$WORK_DIR" "$DIST_DIR"

# Download TravlingRuby for multiple platforms
cd "$WORK_DIR"

echo "Downloading TravlingRuby binaries..."
# Linux x86_64
curl -L -o traveling-ruby-linux-x86_64.tar.gz \
  https://d6r77u531qvzrn.cloudfront.net/releases/traveling-ruby-20210206-3.0.0-linux-x86_64.tar.gz

# macOS x86_64
curl -L -o traveling-ruby-macos.tar.gz \
  https://d6r77u531qvzrn.cloudfront.net/releases/traveling-ruby-20210206-3.0.0-osx.tar.gz

# Windows
curl -L -o traveling-ruby-windows.tar.gz \
  https://d6r77u531qvzrn.cloudfront.net/releases/traveling-ruby-20210206-3.0.0-win32.tar.gz

echo "Building packages for each platform..."

# Function to build package for a platform
build_package() {
  local platform=$1
  local tarball=$2
  
  echo "Building for ${platform}..."
  
  mkdir -p "${platform}/ruby"
  cd "${platform}/ruby"
  tar xzf "../../${tarball}"
  cd -
  
  # Copy app files
  mkdir -p "${platform}/${APP_DIR}"
  cp -r ../../{lib,bin,Gemfile,Gemfile.lock,collections} "${platform}/${APP_DIR}/"
  cp ../../ruby-rest-runner.gemspec "${platform}/${APP_DIR}/"
  
  # Create wrapper script
  if [[ "$platform" == "windows" ]]; then
    cat > "${platform}/${APP_DIR}/rest-run.bat" << 'BATCHEOF'
@echo off
SETLOCAL
if not exist "%~dp0ruby\bin\ruby.exe" (
  echo Error: Ruby not found in %~dp0ruby\bin
  exit /b 1
)
cd "%~dp0"
"%~dp0ruby\bin\ruby.exe" -Ilib bin/rest-run %*
ENDLOCAL
BATCHEOF
  else
    cat > "${platform}/${APP_DIR}/rest-run" << 'BASHEOF'
#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
exec "$SCRIPT_DIR/ruby/bin/ruby" -I"$SCRIPT_DIR/lib" "$SCRIPT_DIR/bin/rest-run" "$@"
BASHEOF
    chmod +x "${platform}/${APP_DIR}/rest-run"
  fi
  
  # Bundle dependencies
  mkdir -p "${platform}/bundle"
  cd "${platform}/bundle"
  
  if [[ "$platform" == "windows" ]]; then
    ../../windows/ruby/bin/gem install bundler
    cd "${APP_DIR}"
    ../../ruby/bin/bundle install --deployment --without development test
  else
    ../../${platform}/ruby/bin/gem install bundler
    cd "${APP_DIR}"
    ../../${platform}/ruby/bin/bundle install --deployment --without development test
  fi
  
  cd - 2>/dev/null || return
  
  # Create archive
  if [[ "$platform" == "windows" ]]; then
    zip -r "../../${DIST_DIR}/ruby-rest-runner-${VERSION}-${platform}.zip" "${platform}/${APP_DIR}"
  else
    tar czf "../../${DIST_DIR}/ruby-rest-runner-${VERSION}-${platform}.tar.gz" "${platform}/${APP_DIR}"
  fi
  
  echo "✓ ${platform} package created"
}

build_package "linux-x86_64" "traveling-ruby-linux-x86_64.tar.gz"
build_package "macos" "traveling-ruby-macos.tar.gz"
build_package "windows" "traveling-ruby-windows.tar.gz"

echo ""
echo "✓ All packages built successfully in $DIST_DIR/"
ls -lh "$DIST_DIR/"
```

### 3. Make Script Executable

```bash
chmod +x build_traveling_ruby.sh
```

### 4. Build Packages

```bash
./build_traveling_ruby.sh
```

This creates self-contained packages in the `dist/` directory for each platform.

## Distribution

The built packages can be distributed directly:

### Linux
```bash
tar xzf ruby-rest-runner-1.0.0-linux-x86_64.tar.gz
cd ruby-rest-runner-1.0.0
./rest-run --help
```

### macOS
```bash
tar xzf ruby-rest-runner-1.0.0-macos.tar.gz
cd ruby-rest-runner-1.0.0
./rest-run --help
```

### Windows
```cmd
unzip ruby-rest-runner-1.0.0-windows.zip
cd ruby-rest-runner-1.0.0
rest-run.bat --help
```

## Advantages

✅ **No Ruby Installation Required** - Users don't need Ruby 3.4+  
✅ **Single Command** - Just extract and run  
✅ **Cross-Platform** - Same process for Windows, macOS, Linux  
✅ **Version Locked** - References specific Ruby version  
✅ **Small Footprint** - ~50MB per platform  

## Disadvantages

❌ **Package Size** - 50-100MB per platform variant  
❌ **Ruby Version Locked** - Difficult to upgrade Ruby without rebuilding  
❌ **Maintenance** - Need to rebuild for Ruby updates  

## Troubleshooting

### Ruby Not Found Error

On Linux/macOS, ensure the wrapper script is executable:
```bash
chmod +x ruby-rest-runner-1.0.0/rest-run
```

### On Windows, rest-run.bat Doesn't Run

Add the directory to PATH or call it explicitly:
```cmd
C:\path\to\ruby-rest-runner-1.0.0\rest-run.bat exec collections/demo.yml
```

### SSL Certificate Issues

If you see SSL errors, ensure your system has updated CA certificates:

**Linux/macOS:**
```bash
update-ca-certificates
```

**Windows:**
Run the Ruby installation with elevated privileges to update certificates.

## Updating TravlingRuby

To build with a newer Ruby version:

1. Find the latest TravlingRuby release: https://github.com/phusion/traveling-ruby/releases
2. Update the URLs in `build_traveling_ruby.sh`
3. Rebuild packages

## References

- [TravlingRuby GitHub](https://github.com/phusion/traveling-ruby)
- [TravlingRuby Releases](https://d6r77u531qvzrn.cloudfront.net)
- [Ruby Packaging Guide](https://guides.rubyonrails.org/command_line.html#packaging)
