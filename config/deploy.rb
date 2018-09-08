# config valid only for current version of Capistrano
lock '3.3.5'

set :application, "ezgolfleague"
set :repo_url, "git@github.com:dopp10/ezgolfleague.git"

set :stages, ["staging", "production"]
set :default_stage, "production"

set :resque_environment_task, true
set :resque_log_file, "log/resque.log"

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

      execute :sudo, "chown daemon -R #{current_path}/public/assets"
      execute :sudo, "chmod 777 -R #{current_path}/public/assets"
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
