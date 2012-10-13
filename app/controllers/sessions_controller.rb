class SessionsController < ApplicationController
  def create
    user = User.from_omniauth(env['omniauth.auth'])
    self.current_user = user.id
    redirect_to play_url
  end

  def destroy
    self.current_user = nil
    redirect_to root_url
  end
end
