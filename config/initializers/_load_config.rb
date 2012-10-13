# Loads keys for the current app

path = File.read("#{Rails.root}/config/config.yml")

APP_CONF = ActiveSupport::HashWithIndifferentAccess.new(
  YAML.load(ERB.new(path).result)[Rails.env]
)

