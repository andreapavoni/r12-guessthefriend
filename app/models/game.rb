class Game < ActiveRecord::Base
  belongs_to :user

  validates :target, :guesses, :user_id, presence: true

  serialize :target
  serialize :guesses

  def self.by_token(token)
    where(token: token).first
  end

  def self.make(user, token)
    new.tap do |g|
      g.token = token

      # Gamer
      g.user_id = user.id

      # Target
      g.target = user.friend(user.possibly_close_friends.sample)

      # Guesses
      g.guesses = user.friends(limit: 23, except: g.target['id']).shuffle!

      g.save!
    end
  end

  def people
    (self.guesses + [self.target]).shuffle!
  end
end
