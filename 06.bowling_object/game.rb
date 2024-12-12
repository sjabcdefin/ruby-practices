# frozen_string_literal: true

require_relative './frame'

class Game
  def initialize
    @frames = split_into_frames
  end

  def split_into_frames
    scores = ARGV[0].split(',')
    frames = []
    frame = []

    scores.each do |s|
      frame << s

      if frames.size < 9 && (frame.size >= 2 || s == 'X')
        frames << Frame.new(*frame)
        frame.clear
      end
    end

    frames << Frame.new(*frame, final: true)
    frames
  end

  def point
    point = 0
    (0..9).each do |num|
      frame, next_frame, after_next_frame = @frames.slice(num, 3)
      point += frame.total_score(next_frame, after_next_frame)
    end
    point
  end
end
