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

  # Get friends ready for the game. We need a *close friend* to make
  # the guess easier, then the remaining 23 picked from *all friends*
  #
  def friends(options={})
    options =  {limit: 10}.merge(options)
    q = [ 'id in (select uid2 from #friends)' ]

    if target_id = options[:except]
      q.push "id != #{target_id}"
    end

    remaining_friends = facebook.fql_multiquery(
      friends: "select uid2 from friend where uid1 = me()",
      detail: "select id, name, pic from profile where #{q.join(' AND ')}"
    )['detail'].sample(options[:limit])
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

      filter = lambda {|u| u['name'] != 'Facebook User' }

      friends = facebook.get_connections(:me, :statuses).inject(Hash.new(0)) do |friends, status|
        if status['likes'].present?
          status['likes']['data'].each {|u| friends[u['id']] += 1 if filter.call(u) }
        end

        if status['comments'].present?
          status['comments']['data'].each {|u| friends[u['from']['id']] += 1 if filter.call(u['from']) }
        end

        if status['tags'].present?
          status['tags']['data'].each {|u| friends[u['id']] += 1 if filter.call(u) }
        end

        friends
      end

      friends.sort_by(&:last).map!(&:first).reverse!
    end
  end

  # Facebook API wrapper
  def facebook
    @api ||= Koala::Facebook::API.new(self.oauth_token)
  end
end
