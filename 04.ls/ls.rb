#!/usr/bin/env ruby
# frozen_string_literal: true

def find_file_information
  current_directory = File.absolute_path('.')
  files_absolute = Dir.glob("#{current_directory}/*")
  @files = files_absolute.map { |filename| File.basename(filename) }

  @line_size = 3
  @file_size = @files.size
  quotient = @file_size / @line_size
  remainder = @file_size % @line_size

  @interval = quotient
  @interval = quotient + 1 if remainder != 0

  max_file_size = @files.map(&:length).max
  @space_size = max_file_size + 2

  display_file
end

def display_file
  if @file_size <= @line_size
    puts @files.map { |file| file.ljust(@space_size) }.join
  else
    (0...@interval).each do |num|
      file_array = []
      display = num
      3.times do
        file_array << @files[display]
        display += @interval
      end
      puts file_array.compact.map { |file| file.ljust(@space_size) }.join
    end
  end
end

find_file_information
