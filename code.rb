#!/usr/bin/env ruby

# code_combiner.rb
# This script combines all code files in a directory (and its subdirectories)
# into a single text file, organizing them by their relative path.

require 'pathname'
require 'fileutils'

class CodeCombiner
  attr_reader :target_directory, :output_file, :file_extensions

  def initialize(target_directory: '.', output_file: 'combined_code.txt', file_extensions: ['.rb', '.js', '.html', '.erb', '.css', '.scss'])
    @target_directory = Pathname.new(target_directory).expand_path
    @output_file = output_file
    @file_extensions = file_extensions
  end

  def run
    puts "Starting code combination from: #{target_directory}"
    puts "Output will be written to: #{output_file}"
    
    # Collect all the code files
    code_files = collect_code_files
    puts "Found #{code_files.size} code files"
    
    # Combine all code files into output file
    combine_files(code_files)
    
    puts "Code combination complete!"
  end

  private

  def collect_code_files
    all_files = []
    
    # Walk through all directories and files
    Dir.glob("#{target_directory}/**/*").each do |path|
      next if File.directory?(path)
      next unless file_extensions.include?(File.extname(path))
      
      # Get the relative path from target directory
      relative_path = Pathname.new(path).relative_path_from(target_directory)
      all_files << { path: path, relative_path: relative_path.to_s }
    end
    
    # Sort files by relative path for better organization
    all_files.sort_by { |file| file[:relative_path] }
  end

  def combine_files(files)
    # Create directory for output file if it doesn't exist
    output_dir = File.dirname(output_file)
    FileUtils.mkdir_p(output_dir) unless Dir.exist?(output_dir)
    
    # Write all files to the output file
    File.open(output_file, 'w') do |output|
      output.puts "# COMBINED CODE FROM #{target_directory}"
      output.puts "# Generated on #{Time.now}"
      output.puts "# Total files: #{files.size}"
      output.puts "=" * 80
      output.puts
      
      # Group files by directory for better organization
      current_directory = nil
      
      files.each do |file|
        # Get directory part of the path for grouping
        directory = File.dirname(file[:relative_path])
        
        # Print directory header when directory changes
        if directory != current_directory
          output.puts
          output.puts "=" * 80
          output.puts "# DIRECTORY: #{directory}"
          output.puts "=" * 80
          current_directory = directory
        end
        
        # Write file header and content
        output.puts
        output.puts "#" + "-" * 78
        output.puts "# FILE: #{file[:relative_path]}"
        output.puts "#" + "-" * 78
        
        # Add the file content
        begin
          content = File.read(file[:path])
          output.puts content
        rescue => e
          output.puts "# ERROR READING FILE: #{e.message}"
        end
      end
    end
  end
end

# Parse command-line arguments
if ARGV.empty?
  puts "Usage: ruby code_combiner.rb [TARGET_DIRECTORY] [OUTPUT_FILE]"
  puts "  TARGET_DIRECTORY: The directory containing code to combine (default: current directory)"
  puts "  OUTPUT_FILE: Where to save the combined code (default: combined_code.txt)"
  puts
  puts "Example: ruby code_combiner.rb ./my_project ./output/combined.txt"
  
  # Use defaults if no arguments provided
  target_dir = '.'
  output_file = 'combined_code.txt'
else
  target_dir = ARGV[0] || '.'
  output_file = ARGV[1] || 'combined_code.txt'
end

# Allow customizing file extensions through environment variable
extensions = ENV['CODE_EXTENSIONS'] ? ENV['CODE_EXTENSIONS'].split(',') : nil

# Run the combiner
combiner = CodeCombiner.new(
  target_directory: target_dir,
  output_file: output_file,
  file_extensions: extensions || ['.rb', '.js', '.html', '.erb', '.css', '.scss', '.json', '.yml', '.yaml']
)

combiner.run