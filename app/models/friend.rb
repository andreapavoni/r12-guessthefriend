# Represents a Facebook Friend, and takes care of parsing and extracting
# all available information from it.
#
class Friend
  
  AvailableHints = Clue.all.map &:key.to_sym
  
  AvailableHints.each {|attr| attr_reader attr}

  attr_reader :id, :target

  # +user+: an User instance, the owner of this social graph
  # +id+  : a Facebook User ID
  #
  def initialize(user, id)
    @api    = user.facebook
    @id     = id
    @target = @api.get_object(id)

    gather
  end

  # Returns the name of this Facebook User
  #
  def name
    target['name']
  end

  # Returns true if we have enough information for this user to
  # play a game.
  # We can check if we have a suitable target using: me.random_close_friend.suitable?
  def suitable?
    @suitable ||= begin
      info = AvailableHints.inject([]) do |ary, attr|
        ary.concat Array.wrap(send(attr))
      end

      info.size >= 7
    end
  end

  # Returns the list of the filled attributes for this Friend
  def attributes
    AvailableHints.select {|a| send(a).present?}
  end

  private
    # Gather and conquer - very hacky and dirty and quicky
    #
    def gather
      @likes  = @api.get_connections(id, 'likes',  :limit => 10).map {|x| x['name']}.sample(4)
      @groups = @api.get_connections(id, 'groups', :limit => 10).map {|x| x['name']}.sample(4)
      @events = @api.get_connections(id, 'events', :limit => 10).map {|x| x['name']}.sample(4)

      @bio = if target['bio'].present?
        target['bio'].scan(/(.*)\n?/).first.slice(0, 140)
      end

      @quotes = if target['quotes'].present?
        target['quotes'].scan(/(.*)\n?/).first.slice(0, 140)
      end

      @gender = if target['gender'].present?
        target['gender']
      end

      @relationship_status = if target['relationship_status'].present?
        target['relationship_status']
      end

      @favorite_athletes = if target['favorite_athletes'].present?
        target['favorite_athletes'].
          map {|x| x['name']}.
          reject! {|x| x.count(' ')}
      end

      @languages = if target['languages'].present?
        target['languages'].map {|x| x['name']}
      end

      @birthday = if target['birthday'].present?
        Time.parse(target['birthday']) rescue nil
      end

      @hometown = if target['hometown'].present?
        target['hometown']['name']
      end

      @work = if target['work'].present?
        target['work'].map {|x| x['employer']['name']}
      end
    end
end
