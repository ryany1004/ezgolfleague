server '45.33.23.165', roles: %w{web app db}, user: "root"

set :deploy_to, "/var/web/production/"
set :stage, :production
set :rails_env, :production
