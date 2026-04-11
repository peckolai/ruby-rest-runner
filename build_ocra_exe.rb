#!/usr/bin/env ruby
# frozen_string_literal: true

# OCRA Build Script for ruby-rest-runner
# Packages the application as a standalone Windows .exe

require 'fileutils'
require 'pathname'

class OCRABuilder
  VERSION = "1.0.0"
  OUTPUT_DIR = "dist"
  
  def initialize
    @root_dir = File.dirname(__FILE__)
    @lib_dir = File.join(@root_dir, 'lib')
    @bin_dir = File.join(@root_dir, 'bin')
    @bin_script = File.join(@bin_dir, 'rest-run')
    @collections_dir = File.join(@root_dir, 'collections')
    @gemfile = File.join(@root_dir, 'Gemfile')
  end

  def build
    puts "=" * 60
    puts "OCRA Builder for ruby-rest-runner v#{VERSION}"
    puts "=" * 60
    puts ""
    
    # Verify prerequisites
    verify_prerequisites
    
    # Create output directory
    FileUtils.mkdir_p(OUTPUT_DIR)
    puts "✓ Output directory: #{OUTPUT_DIR}/"
    
    # Build OCRA command
    ocra_cmd = build_ocra_command
    
    puts ""
    puts "Building Windows executable..."
    puts "This may take 2-5 minutes..."
    puts ""
    
    # Execute OCRA
    unless system(ocra_cmd)
      puts "✗ Build failed"
      exit 1
    end
    
    # Verify output
    exe_path = File.join(OUTPUT_DIR, "rest-run.exe")
    if File.exist?(exe_path)
      size_mb = (File.size(exe_path) / (1024.0 * 1024)).round(2)
      
      puts ""
      puts "=" * 60
      puts "✓ Build successful!"
      puts "=" * 60
      puts ""
      puts "Output: #{exe_path}"
      puts "Size:   #{size_mb} MB"
      puts ""
      puts "Next steps:"
      puts "  1. Test locally:  #{exe_path} --help"
      puts "  2. Distribute:    Copy rest-run.exe to target machine"
      puts "  3. Run:           rest-run.exe exec collections/demo.yml"
      puts ""
      puts "Optional: Create installer with NSIS"
      puts "  See INSTALL_OCRA.md for Windows installer setup"
      puts ""
    else
      puts "✗ Executable not found at #{exe_path}"
      exit 1
    end
  end

  private

  def verify_prerequisites
    puts "Verifying prerequisites..."
    
    # Check for Ruby
    ruby_version = `ruby --version`.strip
    puts "✓ Ruby: #{ruby_version}"
    
    # Check for OCRA gem
    begin
      require 'ocra'
      puts "✓ OCRA gem installed"
    rescue LoadError
      puts "✗ OCRA gem not found"
      puts ""
      puts "Install OCRA with:"
      puts "  gem install ocra"
      puts ""
      exit 1
    end
    
    # Check for main entry point
    unless File.exist?(@bin_script)
      puts "✗ Main script not found: #{@bin_script}"
      exit 1
    end
    puts "✓ Main script: #{@bin_script}"
    
    # Check for Gemfile
    unless File.exist?(@gemfile)
      puts "✗ Gemfile not found: #{@gemfile}"
      exit 1
    end
    puts "✓ Gemfile: #{@gemfile}"
    
    # Check for lib directory
    unless Dir.exist?(@lib_dir)
      puts "✗ lib directory not found: #{@lib_dir}"
      exit 1
    end
    puts "✓ lib directory: #{@lib_dir}"
    
    puts ""
  end

  def build_ocra_command
    cmd_parts = [
      "ocra",
      "--output #{File.join(OUTPUT_DIR, 'rest-run.exe')}",
      "--chdir-first",
      "--add-all-core",
      "--no-lzma"
    ]
    
    # Add icon if it exists
    icon_path = File.join(@root_dir, 'rest-run.ico')
    if File.exist?(icon_path)
      cmd_parts << "--icon #{icon_path}"
    end
    
    # Add application files
    cmd_parts << @bin_script
    
    # Add library directory
    Dir.glob("#{@lib_dir}/**/*.rb").each do |file|
      cmd_parts << file
    end
    
    # Include Gemfile for bundler
    cmd_parts << @gemfile
    
    # Add sample collections (read-only reference)
    if Dir.exist?(@collections_dir)
      Dir.glob("#{@collections_dir}/*.yml").each do |file|
        cmd_parts << "--add #{file}"
      end
    end
    
    cmd_parts.join(" ")
  end
end

# Run builder
if __FILE__ == $0
  builder = OCRABuilder.new
  builder.build
end
