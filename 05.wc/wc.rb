#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

INTERVAL = 7

def command_line_option
  opts = OptionParser.new
  options = { l_option: false, w_option: false, c_option: false }
  opts.on('-l') { options[:l_option] = true }
  opts.on('-w') { options[:w_option] = true }
  opts.on('-c') { options[:c_option] = true }
  opts.parse!(ARGV)
  options
end

def calculate_files_lines_words_bytes(files)
  files.map do |file|
    file_content = File.read(file)
    files_statistics = calculate_lines_words_bytes(file_content)
    files_statistics[:file] = file
    files_statistics
  end
end

def calculate_max_digits(files_statistics)
  files_statistics.flat_map do |file_statistics|
    [
      file_statistics[:lines].to_s.size,
      file_statistics[:words].to_s.size,
      file_statistics[:bytes].to_s.size
    ]
  end.max
end

def calculate_total(files_statistics)
  files_statistics << {
    lines: files_statistics.sum { |file_statistics| file_statistics[:lines] },
    words: files_statistics.sum { |file_statistics| file_statistics[:words] },
    bytes: files_statistics.sum { |file_statistics| file_statistics[:bytes] },
    file: '合計'
  }
end

def check_options(options, file_statistics)
  if options.value?(true)
    option_check_results = {}
    option_check_results[:lines] = file_statistics[:lines] if options[:l_option]
    option_check_results[:words] = file_statistics[:words] if options[:w_option]
    option_check_results[:bytes] = file_statistics[:bytes] if options[:c_option]
    option_check_results
  else
    file_statistics.slice(:lines, :words, :bytes)
  end
end

def calculate_lines_words_bytes(input)
  {
    lines: input.count("\n"),
    words: input.split.size,
    bytes: input.bytesize
  }
end

def display_wc_results(options, files_statistics, interval)
  files_statistics.each do |file_statistics|
    option_check_results = check_options(options, file_statistics)
    formatted_results = if option_check_results.size == 1 && files_statistics.size == 1
                          option_check_results.values
                        else
                          option_check_results.values.map { |value| format("%#{interval}d", value) }
                        end
    formatted_results << file_statistics[:file] if file_statistics[:file]
    puts formatted_results.join(' ')
  end
end

def run_wc_command
  options = command_line_option
  if ARGV.size.positive?
    files_statistics = calculate_files_lines_words_bytes(ARGV)
    interval = calculate_max_digits(files_statistics)
    files_statistics = calculate_total(files_statistics) if ARGV.size > 1
    display_wc_results(options, files_statistics, interval)
  else
    input = ARGF.read
    input_statistics = calculate_lines_words_bytes(input)
    display_wc_results(options, [input_statistics], INTERVAL)
  end
end

run_wc_command
