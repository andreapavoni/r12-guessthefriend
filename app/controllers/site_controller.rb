class SiteController < ApplicationController
  before_filter :authenticate_user, only: [:play]

  def index
  end

  def play
    @game = Game.where(id: session[:game_id]).first_or_initialize.tap do |g|
      g.user_id = current_user.id
      g.target_id = current_user.possibly_close_friends.sample
      g.save!
    end

    target = current_user.friend @game.target_id

    @friends = current_user.friends(limit: 23, except: @game.target_id)
    (@friends << target).shuffle!
  end

end
