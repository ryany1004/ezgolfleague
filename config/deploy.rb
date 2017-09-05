# config valid only for current version of Capistrano
lock '3.3.5'

set :application, "ezgolfleague"
set :repo_url, "git@github.com:dopp10/ezgolfleague.git"

set :stages, ["staging", "production"]
set :default_stage, "production"

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  desc 'Fix permissions'
  task :fix_permissions do
    on roles(:app), in: :sequence, wait: 5 do
      execute :sudo, "chown daemon -R #{current_path}/log"
      execute :sudo, "chown daemon -R #{current_path}/public"
      execute :sudo, "chown daemon -R #{current_path}/tmp"

      execute :sudo, "chmod 777 -R #{current_path}/log"
      execute :sudo, "chmod 777 -R #{current_path}/public"
      execute :sudo, "chmod 777 -R #{current_path}/tmp"

      execute :sudo, "chown daemon -R /var/web/production/shared/public/assets"
      execute :sudo, "chmod 777 -R /var/web/production/shared/public/assets"
    end
  end

  after :publishing, :restart
  after :publishing, :fix_permissions
  after :finished, 'airbrake:deploy'

  #after "deploy:finished", "airbrake:deploy"

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

require './config/boot'
