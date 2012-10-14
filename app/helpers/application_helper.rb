module ApplicationHelper

  def add_social(partial)
    render partial: "shared/#{partial}"
  end

  def login_path
    '/auth/facebook'
  end

  def profile_pic_for(fb_uid, oauth_token)
    Rails.cache.fetch("user/#{fb_uid}/profile_pic", expires_in: 86400, race_condition_ttl: 5) do
      api = Koala::Facebook::API.new(oauth_token)
      api.get_object(:me, fields: 'picture.type(large)')['picture']['data']['url']
    end
  end
end
