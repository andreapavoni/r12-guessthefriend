class Game < ActiveRecord::Base
  belongs_to :user

  validates :target, :user_id, presence: true

  attr_accessible :hints

  serialize :target
  serialize :guesses
  serialize :hints

  class << self
    def by_token(token)
      where(token: token).first
    end

    def make(user, token)
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

    # Find the Users ordered by their score
    def leaderboard
      self.joins(:user).select('SUM(score) AS score, users.name, users.uid').group('users.name, users.uid').order('sum(score) desc')
    end
  end

  def people
    (self.guesses + [self.target]).shuffle!
  end

  def target_id
    self.target['id']
  end

  # Use the stored current_hint to return the next one, and increment it,
  # wrapping after it reaches hints.size.
  #
  # Returns a String representing the current hint
  def next_hint
    transaction do
      idx = self.current_hint
      update_attribute(:current_hint, (idx += 1) == hints.size ? 0 : idx)
    end

    hints[current_hint]
  end

  def valid_guess?(guess)
    guess == target_id || guesses.find {|g| g['id'] == guess.to_i}
  end

  def eliminate!(id)
    transaction do
      if id == target_id
        guesses.clear
      else
        guesses.reject! {|g| g['id'] == id.to_i}
        update_score!(1)
      end
      save!
    end

    return id != target_id
  end

  def guess!(id)
    transaction do
      if id == target_id
        update_score!(guesses.size * 10)
      end
      guesses.clear
      save!
    end

    return id == self.target_id
  end

  private
  # Updates score for the game, incrementing it by the given number of points
  #
  def update_score!(points)
    increment!(:score, points)
  end
end
