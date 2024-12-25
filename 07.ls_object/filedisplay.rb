# frozen_string_literal: true

require 'optparse'
require_relative 'filedetail'

class FileDisplay
  COLUMN_SIZE = 3
  COLUMN_SPACE = 2

  def initialize
    @options = parse_command_line_options
    @file_names = fetch_file_names
  end

  def display_files
    @file_details = @file_names.map { |file_name| FileDetail.new(file_name) }
    if @options[:l_option]
      max_size_length = calculate_max_size_length
      max_link_length = calculate_max_link_length
      total_blocks = calculate_total_blocks
      puts "合計 #{total_blocks / 2}"
      @file_details.each do |file_detail|
        puts file_detail.formatted_detail(max_size_length, max_link_length)
      end
    else
      output_rows = format_file_names_for_display
      column_width = calculate_column_width
      output_rows.each do |row|
        puts row.compact.map { |file_name| file_name.ljust(column_width) }.join
      end
    end
  end

  private

  def parse_command_line_options
    opts = OptionParser.new
    options = { a_option: false, r_option: false, l_option: false }
    opts.on('-a') { options[:a_option] = true }
    opts.on('-r') { options[:r_option] = true }
    opts.on('-l') { options[:l_option] = true }
    opts.parse!(ARGV)
    options
  end

  def fetch_file_names
    dir_option = @options[:a_option] ? File::FNM_DOTMATCH : 0
    sorted_files = Dir.glob('*', dir_option).sort!
    @options[:r_option] ? sorted_files.reverse : sorted_files
  end

  def format_file_names_for_display
    interval = calculate_interval
    file_names = @file_details.map(&:name)
    file_names.each_slice(interval)
              .to_a
              .map { |column| column.fill(nil, column.size...interval) }
              .transpose
  end

  def calculate_max_size_length
    @file_details.map(&:size_word_count).max
  end

  def calculate_max_link_length
    @file_details.map(&:link_word_count).max
  end

  def calculate_total_blocks
    @file_details.sum(&:block)
  end

  def calculate_interval
    @file_details.size.ceildiv(COLUMN_SIZE)
  end

  def calculate_column_width
    name_lengths = []
    @file_details.each do |file_detail|
      name_lengths << file_detail.name_length
    end
    name_lengths.max + COLUMN_SPACE
  end
end
