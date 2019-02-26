server 'staging.ezgolfleague.com', roles: %w{web app db}, user: "root"

set :deploy_to, "/var/web/staging/"
set :stage, :staging
set :rails_env, :staging
set :branch, 'staging'
set :sidekiq_log => File.join(shared_path, 'log', 'sidekiq.log')