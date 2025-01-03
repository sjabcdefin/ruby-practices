# frozen_string_literal: true

require 'optparse'
require_relative 'filedetail'
require_relative 'filedetailrow'
require_relative 'filenamecolumn'

class FileDisplayPreparation
  def initialize
    @options = parse_command_line_options
    file_names = fetch_file_names
    @file_details = file_names.map { |file_name| FileDetail.new(file_name) }
  end

  def display_files_based_on_format
    file_display_handler = @options[:l_option] ? FileDetailRow.new(@file_details) : FileNameColumn.new(@file_details)
    file_display_handler.display_files
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
end
