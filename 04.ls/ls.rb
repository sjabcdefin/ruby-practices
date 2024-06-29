#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

COLUMN_SIZE = 3
COLUMN_SPACE = 2
FILE_TYPE = { '01' => 'p', '02' => 'c', '04' => 'd', '06' => 'b', '10' => '-', '12' => 'l', '14' => 's' }.freeze
FILE_PERMISSION = { '0' => '---', '1' => '--x', '2' => '-w-', '3' => '-wx', '4' => 'r--', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx' }.freeze
FILE_USER = { 0 => 'root', 1000 => 'tomoka' }.freeze
FILE_GROUP = { 0 => 'root', 1000 => 'tomoka' }.freeze

def configure_command_line_option
  opts = OptionParser.new
  options = { a_option: false, r_option: false }
  opts.on('-a') { options[:a_option] = true }
  opts.on('-r') { options[:r_option] = true }
  opts.on('-l') { options[:l_option] = true }
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

def display_file_and_directory_when_l_option(files)
  (0...files.size).each do |num|
    l_option_file = File::Stat.new(files[num])
    file_mode = format('%06d', l_option_file.mode.to_s(8))
    l_option_mtime = l_option_file.mtime
    file_date_time = { month: l_option_mtime.mon, day: l_option_mtime.day, hour: l_option_mtime.hour, min: l_option_mtime.min }
    l_option_data = []
    l_option_data << FILE_TYPE[file_mode[0, 2]] + (3..5).map { |n| FILE_PERMISSION[file_mode[n, 1]] }.join\
                  << format('%2d', l_option_file.nlink)\
                  << FILE_USER[l_option_file.uid]\
                  << FILE_GROUP[l_option_file.gid]\
                  << format('%4d', l_option_file.size).ljust(5)\
                  << format('%<month>d月 %<day>2d %<hour>02d:%<min>02d', file_date_time)\
                  << files[num]
    puts l_option_data.join(' ')
  end
end

def display_file_and_directory_in_columns(files)
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

def display_file_and_directory
  options = configure_command_line_option
  files = configure_file_name_by_command_line_option(options)
  if options[:l_option]
    display_file_and_directory_when_l_option(files)
  else
    display_file_and_directory_in_columns(files)
  end
end

display_file_and_directory
