#!/usr/bin/env ruby
# frozen_string_literal: true

def find_file_information
  files = Dir.glob('*')
  file_size = files.size
  interval = file_size.ceildiv(LINE_SIZE)
  max_file_size = files.map(&:length).max
  space_size = max_file_size + 2
  display_file(files, interval, space_size)
end

def display_file(files, interval, space_size)
  (0...interval).each do |num|
    file_array = []
    line = num
    3.times do
      file_array << files[line]
      line += interval
    end
    puts file_array.compact.map { |file| file.ljust(space_size) }.join
  end
end

LINE_SIZE = 3
find_file_information
