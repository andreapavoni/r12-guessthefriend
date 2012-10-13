class Game < ActiveRecord::Base
  belongs_to :user

  attr_accessible :target_id, :user_id

  validates :target_id, presence: true
  validates :user_id, presence: true

  def self.by_token(token)
    where(token: token).first
  end

  def self.make(user)
    new.tap do |g|
      g.user_id   = user.id
      g.target_id = user.possibly_close_friends.sample
      g.save!
    end
  end
end
