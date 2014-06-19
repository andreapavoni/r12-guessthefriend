class User < ActiveRecord::Base
  has_many :games

  attr_accessible :name, :oauth_expires_at, :oauth_token, :provider, :uid

  after_create :profile_pic

  class << self
    def from_omniauth(auth)
      where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.name = auth.info.name
        user.oauth_token = auth.credentials.token
        user.oauth_expires_at = Time.at(auth.credentials.expires_at)
        user.save!
      end
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
    choices = friends_sample.shuffle
    loop do
      friend = Friend.new(self, choices.shift)
      return friend if friend.suitable?
    end
  end

  # Get a list of possibly close friends from which we'll pick the one to
  # guess. We use the user's last status updates' likes and comments, as
  # this is an indication of recent activity with those users. To make
  # the game more interesting, it also picks a random set of friends.
  #
  # Returns an Array of Facebook user IDs.
  #
  def friends_sample
    Rails.cache.fetch("user/#{uid}/friends_sample", :expires_in => 120, :race_condition_ttl => 5) do

      filter = lambda {|u| u.present? && u['name'] != 'Facebook User' }

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

      close_friends = friends.keys
      close_friends.delete(self.uid)

      other_friends = facebook.get_connections('me', 'friends', :fields => 'id')
      other_friends.map! {|x| x['id']}.shuffle!

      close_friends + other_friends.take(15)
    end
  end

  # Post a message on friend's wall
  def post_on_friend_wall(msg, friend_id, url)
    facebook.put_wall_post(msg, {name: "Guess The Friend", link: url}, friend_id)
  end

  def profile_pic
    Rails.cache.fetch("user/#{uid}/profile_pic", expires_in: 7200, race_condition_ttl: 5) do
      begin
        self.class.facebook.get_object(self.uid, fields: 'picture.type(large)')['picture']['data']['url']
      rescue Koala::Facebook::APIError
        'https://upload.wikimedia.org/wikipedia/commons/0/09/Man_Silhouette.png'
      end
    end
  end

  # Facebook API wrapper bound to this user
  #
  def facebook
    @api ||= begin
      refresh_access_token!
      Koala::Facebook::API.new(self.oauth_token)
    end
  end

  def refresh_access_token!
    # Checks the saved expiry time against the current time
    if (self.oauth_expires_at - 2.minutes).past?

      # Get the new token
      new_token = self.class.facebook_oauth.exchange_access_token_info(self.oauth_token)

      # Save the new token and its expiry over the old one
      self.oauth_token      = new_token['access_token']
      self.oauth_expires_at = new_token['expires']

      save!
    end
  end

  def self.facebook_oauth
    @facebook_oauth ||= Koala::Facebook::OAuth.new(APP_CONF[:facebook][:app_id], APP_CONF[:facebook][:secret])
  end

  # A client unbound to any user, to fetch profile pics
  def self.facebook
    @facebook ||= Koala::Facebook::API.new
  end

end
