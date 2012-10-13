class Game < ActiveRecord::Base
  belongs_to :user

  validates :target, :guesses, :user_id, presence: true

  attr_accessible :hints

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

  def target_id
    self.target['id']
  end

  # TODO REMOVE ME - hints must be generated in Game.make and serialized to
  # the database.
  def hints
    Friend.hints
  end

  # TODO - do not return a random hint, rather use the stored
  # current_hint_index to return the next one, and increment it,
  # wrapping after it reaches hints.size.
  #
  def next_hint
    hints.sample
  end
end
