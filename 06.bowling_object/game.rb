#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './frame'

class Game
  def initialize
    @frames = parse_input
  end

  def parse_input
    score = ARGV[0]

    scores = score.split(',')

    @frames = []
    frame = []

    scores.each do |s|
      frame << s

      if @frames.size < 10
        if frame.size >= 2 || s == 'X'
          @frames << frame.dup
          frame.clear
        end
      else
        @frames.last << s
      end
    end
    @frames
  end

  def points
    point = 0
    (0..9).each do |n|
      frame, next_frame, after_next_frame = @frames.slice(n, 3)
      next_frame ||= []
      after_next_frame ||= []

      frame_t = Frame.new(frame[0], frame[1], frame[2])
      next_frame_t = Frame.new(next_frame[0], next_frame[1], next_frame[2])
      after_next_frame_t = Frame.new(after_next_frame[0], after_next_frame[1], after_next_frame[2])

      if frame_t.strike?
        point += frame_t.score + next_frame_t.first_shot.score + next_frame_t.second_shot.score
        point += after_next_frame_t.first_shot.score if next_frame_t.first_shot.score == 10
      elsif frame_t.spare?
        point += frame_t.score + next_frame_t.first_shot.score
      else
        point += frame_t.score
      end
    end
    point
  end
end

game = Game.new
puts game.points
