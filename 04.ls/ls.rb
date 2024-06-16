#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

COLUMN_SIZE = 3
COLUMN_SPACE = 2

def set_command_line_option
  command_line_option = nil
  opts = OptionParser.new
  opts.on('-a') { command_line_option = 'a' }
  opts.parse!(ARGV)
  specify_command_line_option(command_line_option)
end

def specify_command_line_option(command_line_option)
  files = Dir.glob('*')
  files = Dir.entries('.').sort! if command_line_option
  find_file_information(files)
end

def find_file_information(files)
  interval = files.size.ceildiv(COLUMN_SIZE)
  max_file_size = files.map(&:length).max
  space_size = max_file_size + COLUMN_SPACE
  display_file(files, interval, space_size)
end

def display_file(files, interval, space_size)
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

set_command_line_option
