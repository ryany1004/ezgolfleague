server 'production.ezgolfleague.com', roles: %w{web app db}, user: "root"

set :deploy_to, "/var/web/staging/"
set :stage, :staging
set :rails_env, :staging
<<<<<<< Updated upstream
=======
set :branch, 'staging'
set :workers, { "staging" => 2 }
set :resque_rails_env, "staging"
>>>>>>> Stashed changes
