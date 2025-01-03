# frozen_string_literal: true

class FileDetailRow
  def initialize(file_details)
    @file_details = file_details
  end

  def display_files
    puts "合計 #{total_blocks / 2}"
    @file_details.each do |file_detail|
      puts file_detail.formatted_detail(max_size_length, max_link_length)
    end
  end

  private

  def max_size_length
    @file_details.map(&:size_word_count).max
  end

  def max_link_length
    @file_details.map(&:link_word_count).max
  end

  def total_blocks
    @file_details.sum(&:block)
  end
end
