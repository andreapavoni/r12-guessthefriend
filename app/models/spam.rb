# Used to track posts on a friend wall
class Spam < ActiveRecord::Base
  attr_accessible :target_id

  def postable?
    self.updated_at <= 15.minutes.ago
  end
end
