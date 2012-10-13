class Game < ActiveRecord::Base
  belongs_to :user

  attr_accessible :target_id, :user_id

  validates :target_id, presence: true
  validates :user_id, presence: true
end
