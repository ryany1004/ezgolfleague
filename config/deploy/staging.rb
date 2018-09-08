server 'staging.ezgolfleague.com', roles: %w{web app db resque_worker resque_scheduler}, user: "root"

set :deploy_to, "/var/web/staging/"
set :stage, :staging
set :rails_env, :staging
set :branch, 'staging'

set :workers, { "default" => 2, "ezgolfleague_production_mailers" => 1 }
set :resque_rails_env, "staging"