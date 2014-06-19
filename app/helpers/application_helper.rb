module ApplicationHelper

  def add_social(partial)
    render partial: "shared/#{partial}"
  end

  def login_path
    '/auth/facebook'
  end

  def profile_pic_url_for(fb_uid, oauth_token)
    User.find_by_uid(fb_uid).profile_pic
  end

  def profile_pic_image_tag_for(player)
    url = profile_pic_url_for(player.uid, player.oauth_token)
    image_tag url, alt: player.name, size: '48x48'
  end
end
