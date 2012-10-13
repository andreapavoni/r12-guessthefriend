require 'bundler/capistrano'

# This capistrano deployment recipe is made to work with the optional
# StackScript provided to all Rails Rumble teams in their Linode dashboard.
#
# After setting up your Linode with the provided StackScript, configuring
# your Rails app to use your GitHub repository, and copying your deploy
# key from your server's ~/.ssh/github-deploy-key.pub to your GitHub
# repository's Admin / Deploy Keys section, you can configure your Rails
# app to use this deployment recipe by doing the following:
#
# 1. Add `gem 'capistrano'` to your Gemfile.
# 2. Run `bundle install --binstubs --path=vendor/bundles`.
# 3. Run `bin/capify .` in your app's root directory.
# 4. Replace your new config/deploy.rb with this file's contents.
# 5. Configure the two parameters in the Configuration section below.
# 6. Run `git commit -a -m "Configured capistrano deployments."`.
# 7. Run `git push origin master`.
# 8. Run `bin/cap deploy:setup`.
# 9. Run `bin/cap deploy:migrations` or `bin/cap deploy`.
#
# Note: When deploying, you'll be asked to enter your server's root
# password. To configure password-less deployments, see below.

#############################################
##                                         ##
##              Configuration              ##
##                                         ##
#############################################

GITHUB_REPOSITORY_NAME = 'r12-team-43'
LINODE_SERVER_HOSTNAME = '198.74.58.152'

#############################################
#############################################

# General Options

set :bundle_flags,               "--deployment"

set :application,                "guesswho"
set :deploy_to,                  "/home/rails"
set :normalize_asset_timestamps, false
set :rails_env,                  "production"

set :user,                       "rails"
set :runner,                     "rails"
set :admin_runner,               "rails"

ssh_options[:forward_agent] = true
ssh_options[:auth_methods]  = %w( publickey )

# SCM Options
set :scm,        :git
set :repository, "git@github.com:railsrumble/#{GITHUB_REPOSITORY_NAME}.git"
set :branch,     "master"
set :use_sudo,   false

# Roles
role :app, LINODE_SERVER_HOSTNAME
role :db,  LINODE_SERVER_HOSTNAME, :primary => true

# Add Configuration Files & Compile Assets
after 'deploy:update_code' do
  # Setup Configuration
  run "cp #{shared_path}/config/database.yml #{release_path}/config/database.yml"

  # Compile Assets
  run "cd #{release_path}; RAILS_ENV=production bundle exec rake assets:precompile"
end

# Restart Unicorn
deploy.task :restart, :roles => :app do
  pid = "#{deploy_to}/.unicorn.pid"
  run "test -f #{pid} && kill -USR2 `cat #{pid}` || true"
end

set :bundle_flags, "--deployment --quiet --binstubs #{deploy_to}/bin"
set :rake,         "bundle exec rake"
