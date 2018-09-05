server 'staging.ezgolfleague.com', roles: %w{web app db}, user: "root"

set :deploy_to, "/var/web/staging/"
set :stage, :staging
set :rails_env, :staging
set :branch, 'staging'
set :workers, { "default" => 2, "ezgolfleague_production_mailers" => 1 }
set :resque_rails_env, "staging"

role :resque_worker, "staging.ezgolfleague.com", user: "root"
role :resque_scheduler, "staging.ezgolfleague.com", user: "root"