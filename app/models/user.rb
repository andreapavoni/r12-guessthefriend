class User < ActiveRecord::Base
  attr_accessible :name, :oauth_expires_at, :oauth_token, :provider, :uid

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end

  # Find all friends
  def get_friends
    facebook.get_connections :me, :friends
  end

  private
  # Facebook API wrapper
  def facebook
    @api ||= Koala::Facebook::API.new(self.oauth_token)
  end

  # Get a list of possibly close friends from which we'll pick the one to
  # guess. We use the user's last status updates' likes and comments, as
  # this is an indication of recent activity with those users.
  #
  # Returns an Array of user IDs to pick from, sorted by frequency they
  # interacted with the current user.
  #
  def possibly_close_friends
    Rails.cache.fetch("user/#{uid}/close_friends", :expires_in => 600, :race_condition_ttl => 5) do
      friends = facebook.get_connections('me', 'statuses').inject(Hash.new(0)) do |friends, status|
        if status['likes'].present?
          status['likes']['data'].each {|l| friends[l['id']] += 1}
        end

        if status['comments'].present?
          status['comments']['data'].each {|c| friends[c['from']['id']] += 1}
        end

        if status['tags'].present?
          status['tags']['data'].each {|c| friends[c['id']] += 1}
        end

        friends
      end

      friends.sort_by(&:last).map!(&:first).reverse!
    end
  end
end
