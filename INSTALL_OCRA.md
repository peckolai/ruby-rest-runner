# OCRA Installation Guide

OCRA (One-Click Ruby Application) is a tool that converts Ruby scripts into standalone Windows executables (.exe files), making it seamless for Windows users.

## What is OCRA?

OCRA packages a Ruby application with the Ruby interpreter into a self-executing Windows installer/executable. Users can run it without installing Ruby.

## Prerequisites

- Windows system (or Windows VM)
- Ruby 3.4+ installed
- OCRA gem
- Git (for cloning the repo)

## Installation Steps

### 1. Install OCRA

```bash
gem install ocra
```

### 2. Clone the Repository

```bash
git clone https://github.com/yourusername/ruby-rest-runner.git
cd ruby-rest-runner
bundle install
```

### 3. Create OCRA Build Script

Create a file named `build_ocra_exe.rb` in the root directory:

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'json'

class OCRABuilder
  VERSION = "1.0.0"
  OUTPUT_DIR = "dist"
  
  def initialize
    @root_dir = File.dirname(__FILE__)
    @lib_dir = File.join(@root_dir, 'lib')
    @bin_dir = File.join(@root_dir, 'bin')
    @collections_dir = File.join(@root_dir, 'collections')
  end

  def build
    puts "Building ruby-rest-runner #{VERSION} as Windows .exe..."
    
    # Create output directory
    FileUtils.mkdir_p(OUTPUT_DIR)
    
    # Collect files to include
    files_to_include = collect_files
    
    # Build OCRA command
    ocra_cmd = build_ocra_command(files_to_include)
    
    puts "Running: #{ocra_cmd}"
    
    # Execute OCRA
    result = system(ocra_cmd)
    
    if result
      exe_path = File.join(OUTPUT_DIR, "rest-run.exe")
      puts "✓ Successfully built: #{exe_path}"
      puts "✓ File size: #{(File.size(exe_path) / (1024.0 * 1024)).round(2)} MB"
      puts ""
      puts "Distribution:"
      puts "  1. Copy rest-run.exe to target machine"
      puts "  2. Double-click or run: rest-run.exe --help"
      puts "  3. Place collections/ directory next to exe for use"
    else
      puts "✗ Build failed"
      exit 1
    end
  end

  private

  def collect_files
    files = []
    
    # Include all Ruby library files
    Dir.glob("#{@lib_dir}/**/*.rb").each { |f| files << f }
    
    # Include bin/rest-run main script
    files << File.join(@bin_dir, 'rest-run')
    
    # Include sample collections (optional)
    if Dir.exist?(@collections_dir)
      Dir.glob("#{@collections_dir}/*.yml").each { |f| files << "-a #{f}" }
    end
    
    # Include Gemfile for dependency resolution
    files << "Gemfile"
    
    files
  end

  def build_ocra_command(files_to_include)
    cmd_parts = [
      "ocra",
      "--output dist/rest-run.exe",
      "--icon rest-run.ico" # Optional: add an icon
    ]
    
    # Add all files to include
    files_to_include.each { |f| cmd_parts << f }
    
    # Main entry point
    cmd_parts << "bin/rest-run"
    
    # Gem optimization
    cmd_parts << "--no-lzma"  # Faster extraction on first run
    cmd_parts << "--add-all-core"
    
    cmd_parts.join(" ")
  end
end

if __FILE__ == $PROGRAM_NAME
  builder = OCRABuilder.new
  builder.build
end
```

### 4. Optional: Create an Icon

Create `rest-run.ico` (or download a Ruby icon). OCRA can use this as the .exe icon:

```bash
# Using ImageMagick to convert PNG to ICO
convert rest-run.png -define icon:auto-resize=256,128,96,64,48,32,16 rest-run.ico
```

### 5. Build the Executable

**From Command Prompt (Windows):**

```cmd
cd ruby-rest-runner
ruby build_ocra_exe.rb
```

Or manually with OCRA:

```cmd
ocra --output dist\rest-run.exe ^
     --add-all-core ^
     --gem-full ^
     bin\rest-run
```

This creates `dist/rest-run.exe`.

## Distribution

### Simple Distribution

1. Copy `rest-run.exe` to target Windows machine
2. Copy `collections/` folder next to the .exe
3. Run: `rest-run.exe --help`

### With Installer (Optional - NSIS)

Create a file named `installer.nsi`:

```nsi
; REST Runner Installer Script for NSIS

!include "MUI2.nsh"

Name "Ruby Rest Runner 1.0.0"
OutFile "ruby-rest-runner-1.0.0-installer.exe"
InstallDir "$PROGRAMFILES\RestRunner"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

Section "Install"
  SetOutPath "$INSTDIR"
  File "dist\rest-run.exe"
  File /r "collections\*.*"
  
  ; Create Start Menu shortcuts
  CreateDirectory "$SMPROGRAMS\RestRunner"
  CreateShortcut "$SMPROGRAMS\RestRunner\REST Runner.lnk" "$INSTDIR\rest-run.exe"
  CreateShortcut "$DESKTOP\REST Runner.lnk" "$INSTDIR\rest-run.exe"
SectionEnd

Section "Uninstall"
  Delete "$SMPROGRAMS\RestRunner\REST Runner.lnk"
  Delete "$DESKTOP\REST Runner.lnk"
  RMDir "$SMPROGRAMS\RestRunner"
  Delete "$INSTDIR\rest-run.exe"
  RMDir "$INSTDIR"
SectionEnd
```

Build the installer:

```bash
# Install NSIS first: https://nsis.sourceforge.io/
makensis installer.nsi
```

## Usage

### Command Line

```cmd
rest-run.exe --help
rest-run.exe exec collections/demo.yml
rest-run.exe exec collections/demo.yml -e production
```

### In PowerShell

```powershell
& "C:\path\to\rest-run.exe" --help
& "C:\path\to\rest-run.exe" exec collections/demo.yml
```

### Add to PATH (Optional)

1. Right-click "This PC" or "My Computer" → Properties
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Under "System variables", select "Path" and click "Edit"
5. Click "New" and add the directory containing `rest-run.exe`
6. Click OK and restart any open shells

Now you can run: `rest-run.exe` from any directory.

## Advantages

✅ **Single Executable** - No installation needed  
✅ **Zero Dependencies** - Ruby included inside .exe  
✅ **Windows Native** - Works like any Windows application  
✅ **Easy Distribution** - Single .exe file (100-200MB)  
✅ **Desktop Integration** - Can create shortcuts  

## Disadvantages

❌ **Large File Size** - ~150-200MB .exe  
❌ **Slow First Start** - Ruby runtime extraction (~5-10 seconds)  
❌ **Windows Only** - Need separate builds for macOS/Linux  
❌ **Antivirus Issues** - May trigger false positives  

## Performance Optimization

### First Run Cache

OCRA caches the extracted Ruby runtime. Create a wrapper script to pre-extract:

```batch
@echo off
REM rest-run-preload.bat - Pre-extracts OCRA cache for faster subsequent runs

if not exist "%APPDATA%\.ruby-rest-runner" (
  echo Preparing REST Runner for first use...
  "%~dp0rest-run.exe" --help > nul
  echo Ready!
) else (
  "%~dp0rest-run.exe" %*
)
```

### Memory Usage

If the .exe uses too much memory:

1. Close other applications
2. Increase available RAM
3. Consider using TravlingRuby instead for production

## Troubleshooting

### "Cannot find Ruby" Error

Ensure the OCRA build completed successfully and check the .exe file size (should be 100+ MB).

### Antivirus False Positives

OCRA executables sometimes trigger antivirus software. Options:

1. **Code Sign the Executable** - Use Microsoft Authenticode
2. **Whitelist** - Add to antivirus exclusions
3. **Use TravlingRuby** - Often triggers fewer warnings

### Collections Not Found

Ensure `collections/` directory is in the same folder as `rest-run.exe`:

```
C:\Users\User\Downloads\
├── rest-run.exe
└── collections/
    ├── demo.yml
    └── api.yml
```

### Slow Startup

First run extracts Ruby (~5-10s). Subsequent runs are faster. To speed up:

1. Let extraction complete on first run
2. OCRA caches in temporary directory
3. Subsequent runs use cached version

## Advanced Features

### Self-Updating REST Runner

Embed a check for updates in the script:

```ruby
# In lib/rest_runner/cli.rb
class CLI
  desc "update", "Check for and install updates"
  def update
    local_version = "1.0.0"
    latest_url = "https://github.com/yourname/ruby-rest-runner/releases/latest"
    
    puts "Checking for updates..."
    # Download latest .exe and replace current one
  end
end
```

### Custom Splash Screen

Use `--windowed-console` flag:

```bash
ocra --windowed-console --output dist\rest-run.exe bin\rest-run
```

## References

- [OCRA GitHub](https://github.com/larisch/ocra)
- [OCRA Documentation](https://github.com/larisch/ocra/wiki)
- [NSIS Installer](https://nsis.sourceforge.io/Docs/)
- [Ruby on Windows Guide](https://rubyinstaller.org/docs/)
- [Code Signing Executables](https://docs.microsoft.com/en-us/windows/win32/seccrypto/using-signtool-to-sign-files)
