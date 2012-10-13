class User < ActiveRecord::Base
  has_many :games

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

  # Get this user's friends. Returns 10 entries by default, change using the
  # :limit option. You can skip a single UID by passing the :except option.
  #
  # Returns an Array of Hashes with the id, name and pic keys.
  #
  def friends(options={})
    options =  {limit: 10}.merge(options)
    q = [ 'id in (select uid2 from #friends)' ]

    if skip = options[:except]
      q.push "id != #{skip}"
    end

    facebook.fql_multiquery(
      friends: "select uid2 from friend where uid1 = me()",
      detail: "select id, name, pic from profile where #{q.join(' AND ')}"
    )['detail'].sample(options[:limit])
  end

  # Gets the given friend ID.
  #
  # Returns an Hash in the same format returned by +friends+.
  def friend(id)
    facebook.fql_query("select id, name, pic from profile where id = #{id}").first
  end

  # Tries to randomly find a suitable close friend who shared enough
  # information to build enough hints to play the game.
  #
  def suitable_close_friend
    choices = possibly_close_friends.shuffle
    loop do
      friend = Friend.new(self, choices.shift)
      return friend if friend.suitable?
    end
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

      friends = friends.sort_by(&:last)
      friends.delete(self.uid)
      friends.map!(&:first).reverse!
    end
  end

  # Facebook API wrapper
  def facebook
    @api ||= Koala::Facebook::API.new(self.oauth_token)
  end
end
