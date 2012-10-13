class ApplicationController < ActionController::Base
  protect_from_forgery

  private
  def authenticate_user
    redirect_to '/auth/facebook' unless current_user
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_user=(id)
    session[:user_id] = id
  end

  def current_game
    session[:game] ||= SecureRandom.hex(12)
  end

  def new_game!
    session[:game] = nil
  end

  helper_method :current_user
end
