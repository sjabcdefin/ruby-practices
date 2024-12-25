# frozen_string_literal: true

require 'optparse'
require_relative 'filedetail'

class FileLister
  COLUMN_SIZE = 3
  COLUMN_SPACE = 2

  def initialize
    @options = parse_command_line_options
    @file_names = fetch_file_names
  end

  def display_files
    @file_details = @file_names.map { |file_name| FileDetail.new(file_name) }
    if @options[:l_option]
      print_file_details
    else
      print_file_names
    end
  end

  private

  def parse_command_line_options
    opts = OptionParser.new
    options = { a_option: false, r_option: false }
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

  def print_file_details
    file_items = calculate_file_detail_items
    puts "合計 #{file_items[:total_blocks] / 2}"
    @file_details.each do |file_detail|
      puts file_detail.formatted_detail(file_items[:max_size_length], file_items[:max_link_length])
    end
  end

  def calculate_file_detail_items
    size_lengths = []
    link_lengths = []
    total_blocks = 0
    @file_details.each do |file_detail|
      size_lengths << file_detail.size_word_count
      link_lengths << file_detail.link_word_count
      total_blocks += file_detail.block
    end
    { max_size_length: size_lengths.max, max_link_length: link_lengths.max, total_blocks: }
  end

  def print_file_names
    file_items = calculate_file_name_items
    file_names = @file_details.map(&:name)
    file_names_per_row = file_names.each_slice(file_items[:interval])
                                   .to_a
                                   .map { |column| column.fill(nil, column.size...file_items[:interval]) }
                                   .transpose
    file_names_per_row.each do |row|
      puts row.compact.map { |file_name| file_name.ljust(file_items[:space_size]) }.join
    end
  end

  def calculate_file_name_items
    name_lengths = []
    @file_details.each do |file_detail|
      name_lengths << file_detail.length
    end
    interval = @file_details.size.ceildiv(COLUMN_SIZE)
    space_size = name_lengths.max + COLUMN_SPACE
    { interval:, space_size: }
  end
end
