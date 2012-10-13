# Represents a Facebook Friend, and takes care of parsing and extracting
# all available information from it.
#
class Friend
  Attributes = [
    :gender, :athletes, :languages, :birthday, :hometown, :work, :likes,
    :groups, :events, :bio, :quotes
  ]

  Attributes.each {|attr| attr_reader attr}

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
  def suitable?
    @suitable ||= begin
      info = Attributes.inject([]) do |ary, attr|
        ary.concat Array.wrap(send(attr))
      end

      info.size > 5
    end
  end

  # Returns the list of the filled attributes for this Friend
  def attributes
    Attributes.select {|a| send(a).present?}
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

      @relationship = if target['relationship_status'].present?
        target['relationship_status']
      end

      @athletes = if target['favorite_athletes'].present?
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
