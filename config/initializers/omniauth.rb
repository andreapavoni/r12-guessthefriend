OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, APP_CONF[:facebook][:app_id], APP_CONF[:facebook][:secret],
    scope: 'user_about_me,user_status,friends_activities,friends_about_me,friends_birthday,friends_checkins,friends_events,friends_groups,friends_hometown,friends_interests,friends_likes,friends_relationships,friends_status,friends_work_history'
end
