#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './frame'

class Game
  def initialize
    @frames = split_into_frames
  end

  def split_into_frames
    score = ARGV[0]

    scores = score.split(',')

    frames = []
    frame = []

    scores.each do |s|
      frame << s

      if frames.size < 10
        if frame.size >= 2 || s == 'X'
          frames << frame.dup
          frame.clear
        end
      else
        frames.last << s
      end
    end
    frames
  end

  def point
    point = 0
    (0..9).each do |n|
      frame_data, next_frame_data, after_next_frame_data = @frames.slice(n, 3)
      next_frame_data ||= []
      after_next_frame_data ||= []

      frame = Frame.new(frame_data[0], frame_data[1], frame_data[2])
      next_frame = Frame.new(next_frame_data[0], next_frame_data[1], next_frame_data[2])
      after_next_frame = Frame.new(after_next_frame_data[0], after_next_frame_data[1], after_next_frame_data[2])

      if frame.strike?
        point += frame.score + next_frame.first_shot.score + next_frame.second_shot.score
        point += after_next_frame.first_shot.score if next_frame.first_shot.score == 10
      elsif frame.spare?
        point += frame.score + next_frame.first_shot.score
      else
        point += frame.score
      end
    end
    point
  end
end

game = Game.new
puts game.point
