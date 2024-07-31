#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def configure_command_line_option
  opts = OptionParser.new
  options = { l_option: false, w_option: false, c_option: false }
  opts.on('-l') { options[:l_option] = true }
  opts.on('-w') { options[:w_option] = true }
  opts.on('-c') { options[:c_option] = true }
  opts.parse!(ARGV)
  options
end

def configure_the_result_of_wc(files)
  wc_array = []
  size_array = []
  files.each do |file|
    file_content = File.read(file)
    file_attribute = File::Stat.new(file)
    wc_list = [
      file_content.count("\n"),
      file_content.split.size,
      file_attribute.size,
      file
    ]
    wc_array << wc_list
    size_array << wc_list[0, 3]
  end
  max_size = size_array[0, 3].flatten.max.to_s.size
  [wc_array, max_size]
end

def configure_total(wc_array)
  total = [
    wc_array.transpose[0].sum,
    wc_array.transpose[1].sum,
    wc_array.transpose[2].sum,
    '合計'
  ]
  wc_array << total
end

def display_the_result_of_wc(options, option_number, wc_total_array, max_size)
  wc_total_array.each do |array|
    wc_display_array = [
      (execute_each_option(array, 0, max_size) if options[:l_option] || option_number.zero?),
      (execute_each_option(array, 1, max_size) if options[:w_option] || option_number.zero?),
      (execute_each_option(array, 2, max_size) if options[:c_option] || option_number.zero?),
      execute_each_option(array, 3)
    ]
    wc_display_array.delete(nil)
    puts wc_display_array.join(' ')
  end
end

def split_files(files, replace_spaces: false)
  content = replace_spaces ? files.gsub(/\s+/, "\n") : files
  content.split(/(\n)/)
end

def configure_lines_words_bytes(wc_array, wc_line_break_array)
  words = 0
  bytes = 0
  wc_line_break_array.each do |file|
    words += file.split.size
    bytes += file.bytesize
  end
  [wc_array.size, words, bytes]
end

def configure_with_ls_command(files)
  wc_line_break_array = split_files(files)
  wc_array = wc_line_break_array[0].include?('合計') ? files.split("\n") : split_files(files, true)
  configure_lines_words_bytes(wc_array, wc_line_break_array)
end

def display_the_result_of_wc_with_ls(options, option_number, result_array)
  wc_display_array = []
  display_number = 0
  options.each_with_index do |value, key|
    next unless value[1] || option_number.zero?

    case option_number
    when 0, 2, 3
      display_number += 1
      format_string = display_number == 1 ? '%7d' : '%8d'
      wc_display_array << format(format_string, result_array[key])
    when 1
      wc_display_array << result_array[key]
    end
  end
  puts wc_display_array.join
end

def execute_each_option(array, index, max_size = 0)
  if (0..2).cover?(index)
    format("%#{max_size}d", array[index])
  else
    array[index]
  end
end

def run_wc_command
  options = configure_command_line_option
  option_number = 0
  options.each { |option| option_number += 1 if option[1] }
  if ARGV.size.positive?
    wc_array, max_size = configure_the_result_of_wc(ARGV)
    wc_total_array = configure_total(wc_array) if ARGV.size > 1
    display_the_result_of_wc(options, option_number, wc_total_array, max_size)
  else
    input = ARGF.read
    result_array = configure_with_ls_command(input)
    display_the_result_of_wc_with_ls(options, option_number, result_array)
  end
end

run_wc_command
