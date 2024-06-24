#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

COLUMN_SIZE = 3
COLUMN_SPACE = 2

def configure_command_line_option
  opts = OptionParser.new
  options = { a_option: false, r_option: false }
  opts.on('-a') { options[:a_option] = true }
  opts.on('-r') { options[:r_option] = true }
  opts.parse!(ARGV)
  options
end

def configure_file_name_by_command_line_option(options)
  dir_option = options[:a_option] ? File::FNM_DOTMATCH : 0
  files = Dir.glob('*', dir_option).sort!
  options[:r_option] ? files.reverse : files
end

def configure_file_interval_and_space_size(files)
  interval = files.size.ceildiv(COLUMN_SIZE)
  max_file_size = files.map(&:length).max
  space_size = max_file_size + COLUMN_SPACE
  [interval, space_size]
end

def display_file_and_directory_in_columns
  options = configure_command_line_option
  files = configure_file_name_by_command_line_option(options)
  interval, space_size = configure_file_interval_and_space_size(files)

  (0...interval).each do |num|
    file_array = []
    line = num
    COLUMN_SIZE.times do
      file_array << files[line]
      line += interval
    end
    puts file_array.compact.map { |file| file.ljust(space_size) }.join
  end
end

display_file_and_directory_in_columns
