#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

COLUMN_SIZE = 3
COLUMN_SPACE = 2
FILE_TYPE = { '01' => 'p', '02' => 'c', '04' => 'd', '06' => 'b', '10' => '-', '12' => 'l', '14' => 's' }.freeze
FILE_PERMISSION = { '0' => '---', '1' => '--x', '2' => '-w-', '3' => '-wx', '4' => 'r--', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx' }.freeze
FILE_USER = { 0 => 'root', Process.uid => Etc.getpwuid(Process.uid).name }.freeze
FILE_GROUP = { 0 => 'root', Process.gid => Etc.getgrgid(Process.gid).name }.freeze

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

def configure_max_nlink_size_block(files)
  max_sizes, max_nlinks, number_of_block = [], [], 0
  files.each do |file|
    file_attribute = File::Stat.new(file)
    max_sizes << file_attribute.size.to_s.size
    max_nlinks << file_attribute.nlink.to_s.size
    number_of_block += file_attribute.blocks
  end
  { max_sizes:, max_nlinks:, number_of_block: }
end

def display_attributes(files)
  numbers = configure_max_nlink_size_block(files)
  puts "合計 #{numbers[:number_of_block] / 2}"
  files.each do |file|
    file_attribute = File::Stat.new(file)
    file_mode = format('%06d', file_attribute.mode.to_s(8))
    modify_time = file_attribute.mtime
    file_date_time = { month: modify_time.mon, day: modify_time.day, hour: modify_time.hour, min: modify_time.min }
    display_items = [
      FILE_TYPE[file_mode[0, 2]] + (3..5).map { |n| FILE_PERMISSION[file_mode[n, 1]] }.join,
      format("%#{numbers[:max_nlinks].max}d", file_attribute.nlink),
      FILE_USER[file_attribute.uid],
      FILE_GROUP[file_attribute.gid],
      format("%#{numbers[:max_sizes].max}d ", file_attribute.size).ljust(numbers[:max_sizes].max),
      format('%<month>d月 %<day>2d %<hour>02d:%<min>02d', file_date_time),
      file
    ]
    puts display_items.join(' ')
  end
end

def display_names_in_columns(files)
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

def display_file_list
  options = configure_command_line_option
  files = configure_file_name_by_command_line_option(options)
  if options[:l_option]
    display_attributes(files)
  else
    display_names_in_columns(files)
  end
end

display_file_list
