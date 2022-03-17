# frozen_string_literal: true

require_relative 'frame'

class Game
  attr_reader :frames

  def initialize(input_string)
    @frames = Frame.create_frames(input_string)
  end

  def total_score
    result = 0
    frames.each do |frame|
      result += frame.score
    end
    result
  end
end
