#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

COLUMN_SIZE = 3
COLUMN_SPACE = 2

def configure_command_line_option
  command_line_option = nil
  opts = OptionParser.new
  opts.on('-a') { command_line_option = 'a' }
  opts.parse!(ARGV)
  command_line_option
end

def configure_file_name_by_command_line_option(command_line_option)
  if command_line_option
    Dir.glob('*', File::FNM_DOTMATCH).sort!
  else
    Dir.glob('*')
  end
end

def configure_file_information(files)
  interval = files.size.ceildiv(COLUMN_SIZE)
  max_file_size = files.map(&:length).max
  space_size = max_file_size + COLUMN_SPACE
  [interval, space_size]
end

def display_file_and_directory_in_3_columns
  command_line_option = configure_command_line_option
  files = configure_file_name_by_command_line_option(command_line_option)
  interval, space_size = configure_file_information(files)

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

display_file_and_directory_in_3_columns
