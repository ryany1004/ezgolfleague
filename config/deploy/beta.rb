server 'beta.ezgolfleague.com', roles: %w{web app}, user: "root"

set :deploy_to, "/var/web/beta/"
set :stage, :beta
set :rails_env, :beta
set :branch, 'new-ui'
set :sidekiq_log => File.join(shared_path, 'log', 'sidekiq.log')
set :keep_releases, 10