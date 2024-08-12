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

def generate_files_statistics(files)
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
  total = {
    lines: files_statistics.inject(0) { |sum, file_statistics| sum + file_statistics[:lines] },
    words: files_statistics.inject(0) { |sum, file_statistics| sum + file_statistics[:words] },
    bytes: files_statistics.inject(0) { |sum, file_statistics| sum + file_statistics[:bytes] },
    file: '合計'
  }
  files_statistics << total
end

def check_options(options, file_statistics)
  option_check_results = {}
  option_check_results[:lines] = file_statistics[:lines] if options[:l_option] || !options.value?(true)
  option_check_results[:words] = file_statistics[:words] if options[:w_option] || !options.value?(true)
  option_check_results[:bytes] = file_statistics[:bytes] if options[:c_option] || !options.value?(true)
  option_check_results
end

def display_wc_results(options, files_statistics, max_digits)
  files_statistics.each do |file_statistics|
    option_check_results = check_options(options, file_statistics)
    formatted_results = if option_check_results.values.size == 1 && files_statistics.size == 1
                          option_check_results.values
                        else
                          option_check_results.values.map { |value| format("%#{max_digits}d", value) }
                        end
    formatted_results << file_statistics[:file]
    puts formatted_results.join(' ')
  end
end

def calculate_lines_words_bytes(input)
  {
    lines: input.count("\n"),
    words: input.split.size,
    bytes: input.bytesize
  }
end

def display_wc_results_via_pipeline(options, input_statistics)
  option_check_results = check_options(options, input_statistics)
  formatted_results = if option_check_results.values.size > 1
                        option_check_results.values.map.with_index do |value, index|
                          format_string = index.zero? ? '%7d' : '%8d'
                          format(format_string, value)
                        end.join
                      else
                        option_check_results.values
                      end
  puts formatted_results
end

def run_wc_command
  options = configure_command_line_option
  if ARGV.size.positive?
    files_statistics = generate_files_statistics(ARGV)
    max_digits = calculate_max_digits(files_statistics)
    files_statistics = calculate_total(files_statistics) if ARGV.size > 1
    display_wc_results(options, files_statistics, max_digits)
  else
    input = ARGF.read
    input_statistics = calculate_lines_words_bytes(input)
    display_wc_results_via_pipeline(options, input_statistics)
  end
end

run_wc_command
