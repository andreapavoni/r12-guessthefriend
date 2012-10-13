class SiteController < ApplicationController
  before_filter :authenticate_user, only: [:play]
  before_filter :find_game, except: [:index]

  def index
  end

  def play
    @game = Game.make(current_user, current_game) unless @game
  end

  private
    def find_game
      @game = Game.by_token(current_game)
    end

end
