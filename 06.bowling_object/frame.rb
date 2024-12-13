# frozen_string_literal: true

require_relative './shot'

class Frame
  attr_reader :first_shot, :second_shot

  def initialize(first_mark, second_mark = nil, third_mark = nil, final: false)
    @first_shot = Shot.new(first_mark)
    @second_shot = Shot.new(second_mark)
    @third_shot = Shot.new(third_mark)
    @final = final
  end

  def total_score(next_frame, after_next_frame)
    total_score = base_score
    total_score += strike_bonus(next_frame, after_next_frame) if strike?
    total_score += spare_bonus(next_frame) if spare?
    total_score
  end

  protected

  def strike?
    @first_shot.score == STRIKE_SCORE
  end

  private

  def base_score
    [
      @first_shot.score,
      @second_shot.score,
      @third_shot.score
    ].sum
  end

  def spare?
    !strike? && @first_shot.score + @second_shot.score == STRIKE_SCORE
  end

  def final_frame?
    @final
  end

  def strike_bonus(next_frame, after_next_frame)
    return 0 if final_frame?

    bonus = next_frame.first_shot.score + next_frame.second_shot.score
    bonus += after_next_frame.first_shot.score if next_frame.strike? && after_next_frame
    bonus
  end

  def spare_bonus(next_frame)
    if final_frame?
      0
    else
      next_frame.first_shot.score
    end
  end
end
