#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMN_SIZE = 3
COLUMN_SPACE = 2

def find_file_information
  files = Dir.glob('*')
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

find_file_information
