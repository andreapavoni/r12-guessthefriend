OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, APP_CONF[:facebook][:app_id], APP_CONF[:facebook][:secret]
end
