module ApplicationHelper

  def add_social(partial)
    render partial: "shared/#{partial}"
  end

  def login_path
    '/auth/facebook'
  end

end
