# frozen_string_literal: true

class FileNameColumn
  COLUMN_SIZE = 3
  COLUMN_SPACE = 2

  def initialize(file_details)
    @file_details = file_details
    @output_rows = format_file_names_for_display
  end

  def display_files
    @output_rows.each do |row|
      puts row.compact.map { |file_name| file_name.ljust(column_width) }.join
    end
  end

  private

  def format_file_names_for_display
    file_names = @file_details.map(&:name)
    file_names.each_slice(interval)
              .map { |column| column.fill(nil, column.size...interval) }
              .transpose
  end

  def interval
    @file_details.size.ceildiv(COLUMN_SIZE)
  end

  def column_width
    @file_details.map(&:name_length).max + COLUMN_SPACE
  end
end
