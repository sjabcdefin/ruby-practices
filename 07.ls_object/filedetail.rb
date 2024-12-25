# frozen_string_literal: true

require 'etc'
require 'active_support/all'

class FileDetail
  FILE_TYPE = { '01' => 'p', '02' => 'c', '04' => 'd', '06' => 'b', '10' => '-', '12' => 'l', '14' => 's' }.freeze
  FILE_PERMISSION = { '0' => '---', '1' => '--x', '2' => '-w-', '3' => '-wx', '4' => 'r--', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx' }.freeze
  FILE_USER = { 0 => 'root', Process.uid => Etc.getpwuid(Process.uid).name }.freeze
  FILE_GROUP = { 0 => 'root', Process.gid => Etc.getgrgid(Process.gid).name }.freeze

  attr_reader :name

  def initialize(name)
    @name = name
    @file = File::Stat.new(name)
    @file_mode = format('%06d', @file.mode.to_s(8))
  end

  def formatted_detail(max_size_length, max_link_length)
    [
      "#{type}#{permission.values.join}",
      format("%#{max_link_length}d", link),
      user,
      group,
      format("%#{max_size_length}d", size),
      format('%<month>2d月 %<day>2d', update_time),
      within_six_months? ? format('%<hour>02d:%<min>02d', update_time) : format('%<year>5d', update_time),
      name
    ].join(' ')
  end

  def link_word_count
    @file.nlink.to_s.size
  end

  def size_word_count
    @file.size.to_s.size
  end

  def block
    @file.blocks
  end

  def length
    @name.size
  end

  private

  def type
    FILE_TYPE[@file_mode[0, 2]]
  end

  def permission
    {
      owner: FILE_PERMISSION[@file_mode[3, 1]],
      group: FILE_PERMISSION[@file_mode[4, 1]],
      other: FILE_PERMISSION[@file_mode[5, 1]]
    }
  end

  def link
    @file.nlink
  end

  def user
    FILE_USER[@file.uid]
  end

  def group
    FILE_GROUP[@file.gid]
  end

  def size
    @file.size
  end

  def update_time
    update_time = @file.mtime
    {
      year: update_time.year,
      month: update_time.mon,
      day: update_time.day,
      hour: update_time.hour,
      min: update_time.min
    }
  end

  def within_six_months?
    @file.mtime >= Time.now.months_ago(6)
  end
end
