server 'staging.ezgolfleague.com', roles: %w{web app db}, user: "root"

set :deploy_to, "/var/web/staging/"
set :stage, :staging
set :rails_env, :staging
set :branch, 'staging'