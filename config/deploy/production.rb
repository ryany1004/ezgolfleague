server 'production.ezgolfleague.com', roles: %w{web app db}, user: "root"

role :resque_worker, "production.ezgolfleague.com", user: "root"
role :resque_scheduler, "production.ezgolfleague.com", user: "root"

set :deploy_to, "/var/web/production/"
set :stage, :production
set :rails_env, :production
set :branch, 'master'
set :workers, { "default" => 2, "ezgolfleague_production_mailers" => 1 }
set :resque_rails_env, "production"