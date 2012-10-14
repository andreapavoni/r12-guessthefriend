module ApplicationHelper

  def google_analytics
    render partial: 'shared/google_analytics'
  end

  def google_plusone
    render partial: 'shared/google_plusone'
  end

  def twitter_button
    render partial: 'shared/twitter_button'
  end

  def facebook_jssdk
    render partial: 'shared/facebook_jssdk'
  end
  
  def facebook_like
    render partial: 'shared/facebook_like'
  end
  
  def login_path
    '/auth/facebook'
  end

end
