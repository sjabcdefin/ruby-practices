#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'date'

class Calendar
  def set_arg
    # コマンドライン引数から年、月の値を取得する
    opt = OptionParser.new
    opt.on('-y [YEAR]') { |v| @year = v.to_i }
    opt.on('-m [MONTH]') { |v| @month = v.to_i }
    opt.parse!(ARGV)

    # 引数指定がなかった場合、現在年月を設定する
    today = Date.today
    @year = today.year if @year.nil?
    return unless @month.nil?

    @month = today.month
  end

  def display_title
    # 年月表示
    year_month = @month.to_s + '月 ' + @year.to_s
    puts year_month.center(20)

    # 曜日表示
    weeks = %w[日 月 火 水 木 金 土]
    puts weeks.join(' ')
  end

  def display_calendar
    lastday = Date.new(@year, @month, -1)
    day = 1
    distance = 2

    while day <= lastday.day
      date = Date.new(@year, @month, day)
      if day == 1
        distance += date.wday * 3
      else
        distance = if date.wday.zero?
                     2
                   else
                     3
                   end
      end
      if date.wday == 6
        puts day.to_s.rjust(distance)
      else
        print day.to_s.rjust(distance)
      end
      day += 1
    end
  end
end

x = Calendar.new
x.set_arg
x.display_title
x.display_calendar
