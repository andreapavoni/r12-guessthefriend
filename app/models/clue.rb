class Clue < ActiveRecord::Base
  attr_accessible :comment, :credits, :guessed, :key, :question_en, :question_it, :used
end
