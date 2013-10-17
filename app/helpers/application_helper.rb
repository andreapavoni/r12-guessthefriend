module ApplicationHelper

  def add_social(partial)
    render partial: "shared/#{partial}"
  end

  def login_path
    '/auth/facebook'
  end

  def profile_pic_for(fb_uid, oauth_token)
    User.find_by_uid(fb_uid).profile_pic
  end
end
