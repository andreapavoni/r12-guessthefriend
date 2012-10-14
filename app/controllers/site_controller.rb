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

  rescue Koala::Facebook::APIError
    self.new_game!
    self.current_user = nil

    redirect_to root_path
  end

  # Returns the next hint for the current game as a JSON string.
  #
  def hint
    render :json => @game.next_hint
  end

  # Abandons the current game and starts a new one.
  #
  def restart
    new_game!
    redirect_to play_path
  end

  # Abandons the current game and redirects to the home page.
  #
  def abandon
    new_game!
    redirect_to root_path
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

    if params[:id] ==  @game.target_id
      head(418)
    else
      @game.update_score!
      head(:ok)
    end
  end

  # Reveals who is the mysterious friend to guess. This sucks, as
  # is the only endpoint you can use to hack the app, but it is needed
  # to make the "I Got It" mode display who was the mysterious friend
  # after you chose the wrong one. Gotcha!
  def reveal
    render :json => @game.target_id
  end

  def leaderboard
    @players = Game.leaderboard.limit(20)
  end

  private
  def find_game
    @game = Game.by_token(current_game)
  end

end
