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

role :resque_worker, "production.ezgolfleague.com"
role :resque_scheduler, "production.ezgolfleague.com"

set :resque_environment_task, true
set :resque_log_file, "log/resque.log"
set :workers, { "default" => 2, "ezgolfleague_production_mailers" => 1 }

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

  desc 'Clear cache'
  task :clear_memcached do
    on roles(:app), in: :sequence, wait: 5 do
      execute "cd #{deploy_to}current && /usr/bin/env bundle exec rake memcached:clear RAILS_ENV=production"
    end
  end

  after :publishing, :restart
  after :publishing, :fix_permissions
  after :finished, 'resque:restart'
  after :finished, :clear_memcached

  set :rollbar_token, '75d79ff8ca4643809de5616d7c6c2265'
  set :rollbar_env, Proc.new { fetch :stage }
  set :rollbar_role, Proc.new { :app }
end

require './config/boot'
