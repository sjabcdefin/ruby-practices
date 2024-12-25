# frozen_string_literal: true

require 'optparse'
require 'etc'
require_relative 'filedetail'

COLUMN_SIZE = 3
COLUMN_SPACE = 2

class FileLister
  def initialize
    @options = parse_command_line_options
    @file_names = fetch_file_names
  end

  def display_files
    @file_details = fetch_file_details
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

  def fetch_file_details
    file_details = []
    @file_names.each do |file_name|
      file_details << FileDetail.new(file_name)
    end
    file_details
  end

  def print_file_details
    file_items = calculate_file_detail_items
    puts "合計 #{file_items[:total_blocks] / 2}"
    @file_details.each do |file_detail|
      puts format_file_detail(file_detail, file_items)
    end
  end

  def calculate_file_detail_items
    size_lengths = []
    link_lengths = []
    total_blocks = 0
    @file_details.each do |file_detail|
      size_lengths << file_detail.size[:word_count]
      link_lengths << file_detail.link[:word_count]
      total_blocks += file_detail.block
    end
    { size_lengths:, link_lengths:, total_blocks: }
  end

  def format_file_detail(file_detail, file_items)
    [
      "#{file_detail.type}#{file_detail.permission.values.join}",
      format("%#{file_items[:link_lengths].max}d", file_detail.link[:number]),
      file_detail.user,
      file_detail.group,
      format("%#{file_items[:size_lengths].max}d", file_detail.size[:number]).ljust(file_items[:size_lengths].max),
      format('%<month>2d月 %<day>2d', file_detail.update_time),
      file_detail.within_six_months? ? format('%<hour>02d:%<min>02d', file_detail.update_time) : format('%<year>5d', file_detail.update_time),
      file_detail.name
    ].join(' ')
  end

  def print_file_names
    file_items = calculate_file_name_items
    (0...file_items[:interval]).each do |num|
      columns = num
      file_name_list = []
      while columns < @file_details.size
        file_name_list << @file_details[columns].name
        columns += file_items[:interval]
      end
      puts file_name_list.compact.map { |file_name| file_name.ljust(file_items[:space_size]) }.join
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
