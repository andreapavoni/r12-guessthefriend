class SiteController < ApplicationController
  before_filter :authenticate_user, only: [:play]
  before_filter :find_game, except: [:index]

  def index
  end

  def play
    @game = Game.make(current_user) unless @game

    target = current_user.friend @game.target_id

    @friends = current_user.friends(limit: 23, except: @game.target_id)
    (@friends << target).shuffle!
  end

  private
    def find_game
      @game = Game.by_token(current_game)
    end

end
