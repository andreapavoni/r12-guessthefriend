# Used to track posts on a friend wall
class Spam < ActiveRecord::Base
  attr_accessible :target_id

  Threshold = 15.minutes

  def self.for(target)
    where(target_id: target).first ||
      create!(target_id: target, updated_at: Threshold.ago)
  end

  def postable?
    self.updated_at <= Threshold.ago
  end
end
