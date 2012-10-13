class SiteController < ApplicationController
  before_filter :authenticate_user, except: [:index]
  before_filter :find_game,         except: [:index]

  # Displays the home page.
  #
  def index
  end

  # Starts a new game if no current game is in progress, or
  # resumes the last played game.
  #
  def play
    @game = Game.make(current_user, current_game) unless @game
  end

  # Returns the next hint for the current game as a JSON string.
  #
  def hint
    render :json => @game.next_hint
  end

  # Abandons the current game and redirects to the home page.
  #
  def restart
    new_game!
    redirect_to play_path
  end

  # Called when an user eliminates a guess. If it is right, then
  # 200 is returned, else 418 - I'm a Teapot ;-).
  #
  # Params:
  #
  #  * id: Facebook User ID of the guess to be eliminated.
  #
  def eliminate
    head :bad_request and return unless params[:id].present?

    head(params[:id] == @game.target_id ? 418 : :ok)
  end

  private
  def find_game
    @game = Game.by_token(current_game)
  end

end
