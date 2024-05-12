#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = []
shots.each_slice(2) do |num|
  frames << num
end

last_frame = []
num = 0
flg = 0

frames.each do |frame|
  if num >= 9
    if frame == [10, 0]
      last_frame << 10
    else
      last_frame << frame[0]
      last_frame << frame[1] if frame.length == 2
    end
    flg += 1
  end
  num += 1
end
frames[9] = last_frame

(1..flg - 1).each do
  frames.pop
end

point = 0
strike = false
spare = false
double = false

frames.each do |frame|
  if double == true
    point += frame[0]
    double = false
  end
  if strike == true
    point += frame[0] + frame[1]
    double = true if frame[0] == 10
  elsif spare == true
    point += frame[0]
  end

  point += frame.sum
  strike = false
  spare = false

  if frame[0] == 10
    strike = true
  elsif frame.sum == 10
    spare = true
  end
end
puts point
