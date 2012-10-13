class SiteController < ApplicationController
  before_filter :authenticate_user, only: [:play]
  before_filter :find_game, except: [:index]

  def index
  end

  def play
    @game = Game.make(current_user, current_game) unless @game
  end

  def restart
    new_game!
    redirect_to root_path
  end

  # Called when an user eliminates a guess. If it is right, then
  # 200 is returned, else 418 - I'm a Teapot ;-).
  #
  # Params:
  #
  #  * guess: Facebook User ID of the guess to be eliminated.
  #
  def eliminate
    head :bad_request and return unless params[:guess].present?

    if params[:guess].to_i == @game.target_id
      head 418
    else
      head :ok
    end
  end

  private
  def find_game
    @game = Game.by_token(current_game)
  end

end
