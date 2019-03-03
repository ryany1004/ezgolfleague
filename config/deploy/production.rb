server 'production.ezgolfleague.com', roles: %w{web app db}, user: "root"

set :deploy_to, "/var/web/production/"
set :stage, :production
set :rails_env, :production
set :branch, 'master'
set :sidekiq_log => File.join(shared_path, 'log', 'sidekiq.log')