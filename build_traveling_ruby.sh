#!/bin/bash
# TravlingRuby Builder for ruby-rest-runner
# Creates self-contained packages for Windows, macOS, and Linux

set -e

VERSION="1.0.0"
WORK_DIR="tmp/traveling-ruby"
APP_NAME="ruby-rest-runner"
DIST_DIR="dist"

# ANSI colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_header() {
  echo ""
  echo "=================================="
  echo "$1"
  echo "=================================="
  echo ""
}

print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
  echo -e "${RED}✗ $1${NC}"
}

print_info() {
  echo -e "${YELLOW}ℹ $1${NC}"
}

# Verify prerequisites
verify_prerequisites() {
  print_header "Verifying Prerequisites"
  
  if ! command -v ruby &> /dev/null; then
    print_error "Ruby not found. Install Ruby 3.4+ first."
    exit 1
  fi
  print_success "Ruby $(ruby --version | cut -d' ' -f2)"
  
  if ! command -v curl &> /dev/null; then
    print_error "curl not found. Install curl first."
    exit 1
  fi
  print_success "curl installed"
  
  if ! command -v tar &> /dev/null; then
    print_error "tar not found. Install tar first."
    exit 1
  fi
  print_success "tar installed"
  
  # Check for unzip on Windows (not needed for Linux/macOS)
  if command -v unzip &> /dev/null; then
    print_success "unzip installed"
  else
    print_info "unzip not found (needed for Windows extraction)"
  fi
}

# Clean up previous builds
cleanup() {
  print_header "Cleaning Previous Builds"
  
  if [ -d "$WORK_DIR" ]; then
    rm -rf "$WORK_DIR"
    print_success "Removed $WORK_DIR"
  fi
  
  if [ -d "$DIST_DIR" ]; then
    rm -rf "$DIST_DIR"
    print_success "Removed $DIST_DIR"
  fi
  
  mkdir -p "$WORK_DIR" "$DIST_DIR"
  print_success "Created working directories"
}

# Build package for a platform
build_platform() {
  local platform=$1
  local ruby_url=$2
  local archive_name=$3
  
  print_header "Building for $platform"
  
  local platform_dir="$WORK_DIR/$platform"
  mkdir -p "$platform_dir"
  cd "$platform_dir"
  
  # Download TravlingRuby
  print_info "Downloading TravlingRuby for $platform..."
  if ! curl -L -o "$archive_name" "$ruby_url"; then
    print_error "Failed to download from $ruby_url"
    cd -
    return 1
  fi
  print_success "Downloaded $(du -h $archive_name | cut -f1)"
  
  # Extract
  print_info "Extracting Ruby runtime..."
  tar -xzf "$archive_name"
  rm "$archive_name"
  print_success "Ruby extracted"
  
  # Copy application
  print_info "Copying application files..."
  local app_dir="${APP_NAME}-${VERSION}"
  mkdir -p "$app_dir"
  
  # Copy essential files
  cp -r ../../{lib,bin,Gemfile,Gemfile.lock,ruby-rest-runner.gemspec} "$app_dir/" 2>/dev/null || true
  
  # Create wrapper script
  if [[ "$platform" == "windows" ]]; then
    cat > "$app_dir/rest-run.bat" << 'BATCHEOF'
@echo off
SETLOCAL
if not exist "%~dp0ruby\bin\ruby.exe" (
  echo Error: Ruby not found in %~dp0ruby\bin
  echo Please ensure the ruby-rest-runner package is properly installed.
  exit /b 1
)
cd "%~dp0"
"%~dp0ruby\bin\ruby.exe" -Ilib bin/rest-run %*
ENDLOCAL
BATCHEOF
    print_success "Created rest-run.bat wrapper"
  else
    cat > "$app_dir/rest-run" << 'BASHEOF'
#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ ! -d "$SCRIPT_DIR/ruby/bin" ]; then
  echo "Error: Ruby not found in $SCRIPT_DIR/ruby/bin"
  echo "Please ensure the package is properly installed."
  exit 1
fi
exec "$SCRIPT_DIR/ruby/bin/ruby" -I"$SCRIPT_DIR/lib" "$SCRIPT_DIR/bin/rest-run" "$@"
BASHEOF
    chmod +x "$app_dir/rest-run"
    print_success "Created rest-run wrapper script"
  fi
  
  # Install gems
  print_info "Installing Ruby gems (this may take 1-2 minutes)..."
  
  if [[ "$platform" == "windows" ]]; then
    cd "$app_dir"
    ../ruby/bin/gem install bundler --quiet
    ../ruby/bin/bundle install --deployment --without development test --quiet
  else
    cd "$app_dir"
    ../ruby/bin/gem install bundler --quiet
    ../ruby/bin/bundle install --deployment --without development test --quiet
  fi
  print_success "Gems installed"
  
  cd - > /dev/null
  
  # Create archive
  print_info "Creating distribution package..."
  if [[ "$platform" == "windows" ]]; then
    if command -v zip &> /dev/null; then
      zip -r "../../$DIST_DIR/${APP_NAME}-${VERSION}-${platform}.zip" "$app_dir" > /dev/null 2>&1
      local archive="../../$DIST_DIR/${APP_NAME}-${VERSION}-${platform}.zip"
    else
      tar -czf "../../$DIST_DIR/${APP_NAME}-${VERSION}-${platform}.tar.gz" "$app_dir"
      local archive="../../$DIST_DIR/${APP_NAME}-${VERSION}-${platform}.tar.gz"
    fi
  else
    tar -czf "../../$DIST_DIR/${APP_NAME}-${VERSION}-${platform}.tar.gz" "$app_dir"
    local archive="../../$DIST_DIR/${APP_NAME}-${VERSION}-${platform}.tar.gz"
  fi
  
  local size=$(du -h "$archive" | cut -f1)
  print_success "Created $archive ($size)"
  
  cd - > /dev/null
}

# Main build process
main() {
  print_header "TravlingRuby Builder for ruby-rest-runner v$VERSION"
  
  verify_prerequisites
  cleanup
  
  # Note: These URLs are examples. Update them to the latest releases
  # from https://d6r77u531qvzrn.cloudfront.net
  
  print_info "Building packages (this will take 5-15 minutes)..."
  print_info "Processing downloads and gem installation..."
  echo ""
  
  # Build for each platform
  # Note: Adjust these URLs to match the latest TravlingRuby releases
  
  echo "Platforms available:"
  echo "  - linux-x86_64"
  echo "  - macos"
  echo "  - windows"
  echo ""
  echo "Downloading and building packages..."
  echo ""
  
  # Linux x86_64
  print_info "Platform 1/3: Linux x86_64"
  build_platform "linux-x86_64" \
    "https://d6r77u531qvzrn.cloudfront.net/releases/traveling-ruby-20210206-3.0.0-linux-x86_64.tar.gz" \
    "traveling-ruby-linux.tar.gz"
  
  # macOS
  print_info "Platform 2/3: macOS"
  build_platform "macos" \
    "https://d6r77u531qvzrn.cloudfront.net/releases/traveling-ruby-20210206-3.0.0-osx.tar.gz" \
    "traveling-ruby-macos.tar.gz"
  
  # Windows
  print_info "Platform 3/3: Windows"
  build_platform "windows" \
    "https://d6r77u531qvzrn.cloudfront.net/releases/traveling-ruby-20210206-3.0.0-win32.tar.gz" \
    "traveling-ruby-windows.tar.gz"
  
  print_header "Build Complete!"
  
  echo ""
  echo "Distribution packages created:"
  echo ""
  ls -lh "$DIST_DIR/" | grep -v "^total" | awk '{print "  " $9 " (" $5 ")"}'
  echo ""
  
  print_success "All platforms built successfully!"
  echo ""
  echo "Next steps:"
  echo "  1. Test locally:"
  echo "     tar xzf $DIST_DIR/${APP_NAME}-${VERSION}-linux-x86_64.tar.gz"
  echo "     cd ${APP_NAME}-${VERSION}"
  echo "     ./rest-run --help"
  echo ""
  echo "  2. Distribute packages from $DIST_DIR/ directory"
  echo ""
  echo "  3. Users can extract and run immediately:"
  echo "     MacOS/Linux: tar xzf *.tar.gz && ./${APP_NAME}-${VERSION}/rest-run --help"
  echo "     Windows:     unzip *.zip && .\\${APP_NAME}-${VERSION}\\rest-run.bat --help"
  echo ""
  
  print_success "Build artifacts ready for distribution"
}

# Run main
main "$@"
