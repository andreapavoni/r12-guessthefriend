class Game < ActiveRecord::Base
  belongs_to :user

  validates :target, :guesses, :user_id, presence: true

  attr_accessible :hints

  serialize :target
  serialize :guesses
  serialize :hints

  def self.by_token(token)
    where(token: token).first
  end

  def self.make(user, token)
    new.tap do |g|
      g.token = token

      # Gamer
      g.user_id = user.id

      # Target
      g.target = user.suitable_close_friend.to_h

      # Guesses
      g.guesses = user.friends(limit: 23, except: g.target['id']).shuffle!

      # Hints
      g.hints = Friend.new(User.find(user.id), g.target['id']).hints

      g.save!
    end
  end

  def people
    (self.guesses + [self.target]).shuffle!
  end

  def target_id
    self.target['id']
  end

  # use the stored current_hint to return the next one, and increment it,
  # wrapping after it reaches hints.size.
  #
  def next_hint
    transaction do
      idx = self.current_hint
      update_attribute(:current_hint, (idx += 1) == hints.size ? 0 : idx)
    end

    hints[current_hint]
  end
end
