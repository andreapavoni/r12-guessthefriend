class SiteController < ApplicationController
  before_filter :authenticate_user, only: [:play]

  def index
  end

  def play
    target_id = current_user.possibly_close_friends.sample
    session[:target_id] = target_id
    target = current_user.friend target_id

    @friends = current_user.friends(limit: 23, except: target_id)
    (@friends << target).shuffle!
  end
end
