module ApplicationHelper
  def google_analytics
    render partial: 'shared/google_analytics'
  end
  def google_plusone
    render partial: 'shared/google_plusone'
  end

  def login_path
    '/auth/facebook'
  end
end
