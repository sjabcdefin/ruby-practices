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

def configure_wc_data(files)
  wc_data = files.map do |file|
    file_content = File.read(file)
    wc_lists = configure_lines_words_bytes(file_content) << file
    wc_lists
  end
  max_digits = wc_data.flat_map { |wc_lists| wc_lists[0, 3] }.max.to_s.size
  { wc_data:, max_digits: }
end

def configure_total(wc_results)
  total = [
    wc_results.transpose[0].sum,
    wc_results.transpose[1].sum,
    wc_results.transpose[2].sum,
    '合計'
  ]
  wc_results << total
end

def check_options(options, wc_results)
  option_check_results = options.map.with_index { |value, index| wc_results[index] if value[1] }
  option_check_results.delete(nil)
  option_check_results.empty? ? wc_results[0, 3] : option_check_results
end

def display_wc_results(options, wc_results, max_digits)
  wc_results.each do |result|
    option_check_results = check_options(options, result)
    formatted_results = if option_check_results.size == 1 && wc_results.size == 1
                          option_check_results
                        else
                          option_check_results.map { |value| format("%#{max_digits}d", value) }
                        end
    formatted_results << result[3]
    puts formatted_results.join(' ')
  end
end

def configure_lines_words_bytes(input)
  [
    input.count("\n"),
    input.split.size,
    input.bytesize
  ]
end

def display_wc_results_via_pipeline(options, wc_results)
  option_check_results = check_options(options, wc_results)
  formatted_results = if option_check_results.size > 1
                        option_check_results.map.with_index do |value, index|
                          format_string = index.zero? ? '%7d' : '%8d'
                          format(format_string, value)
                        end.join
                      else
                        option_check_results
                      end
  puts formatted_results
end

def run_wc_command
  options = configure_command_line_option
  option_number = 0
  options.each { |option| option_number += 1 if option[1] }
  if ARGV.size.positive?
    wc_data = configure_wc_data(ARGV)
    wc_results = wc_data[:wc_data]
    max_digits = wc_data[:max_digits]
    wc_results = configure_total(wc_results) if ARGV.size > 1
    display_wc_results(options, wc_results, max_digits)
  else
    input = ARGF.read
    wc_results = configure_lines_words_bytes(input)
    display_wc_results_via_pipeline(options, wc_results)
  end
end

run_wc_command
