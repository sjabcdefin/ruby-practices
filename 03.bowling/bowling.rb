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

last_frame = frames[9..].map {|n| n==[10,0] ? [10] : n}.flatten
new_frames = frames[0..8].push(last_frame)

point = 0
strike_in_previous_frame = false
spare_in_previous_frame = false
double_in_previous_frame = false

new_frames.each do |frame|
  point += frame[0] if strike_in_previous_frame || spare_in_previous_frame
  point += frame[0] if double_in_previous_frame
  point += frame[1] if strike_in_previous_frame
  point += frame.sum
  double_in_previous_frame = strike_in_previous_frame && frame[0] == 10
  strike_in_previous_frame = frame[0] == 10
  spare_in_previous_frame = !strike_in_previous_frame && frame.sum == 10
end
puts point
