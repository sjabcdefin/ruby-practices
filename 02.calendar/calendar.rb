#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'date'

class Calendar
  def initialize
    opt = OptionParser.new
    opt.on('-y [YEAR]') { |v| @year = v.to_i }
    opt.on('-m [MONTH]') { |v| @month = v.to_i }
    opt.parse!(ARGV)

    today = Date.today
    @year ||= today.year
    @month ||= today.month
  end

  def display_title
    year_month = "#{@month}月 #{@year}"
    puts year_month.center(20)

    weeks = %w[日 月 火 水 木 金 土]
    puts weeks.join(' ')
  end

  def display_calendar
    lastdate = Date.new(@year, @month, -1)

    (1..lastdate.day).each do |num|
      date = Date.new(@year, @month, num)
      distance = 2
      if num == 1
        distance += date.wday * 3
      else
        distance = if date.wday.zero?
                     2
                   else
                     3
                   end
      end
      if date.wday == 6
        puts num.to_s.rjust(distance)
      else
        print num.to_s.rjust(distance)
      end
    end
  end
end

calendar = Calendar.new
calendar.display_title
calendar.display_calendar
