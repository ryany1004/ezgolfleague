server 'production.ezgolfleague.com', roles: %w{web app db resque_worker resque_scheduler}, user: "root"

set :deploy_to, "/var/web/production/"
set :stage, :production
set :rails_env, :production
set :branch, 'master'

set :workers, { "default" => 4, "ezgolfleague_production_mailers" => 2 }
set :resque_rails_env, "production"