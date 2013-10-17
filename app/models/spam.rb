# Used to track posts on a friend wall
class Spam < ActiveRecord::Base
  attr_accessible :target_id, :updated_at

  Threshold = 7.days

  def self.for(target)
    target = target.to_s
    where(target_id: target).first ||
      create!(target_id: target, updated_at: Threshold.ago)
  end

  def postable?
    self.updated_at <= Threshold.ago
  end
end
