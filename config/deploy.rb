# config valid only for current version of Capistrano
lock '3.9.0'

set :application, "ezgolfleague"
set :repo_url, "git@github.com:dopp10/ezgolfleague.git"

set :stages, ["staging", "production", "beta"]
set :default_stage, "production"

set :init_system, :systemd
set :service_unit_name, "sidekiq.service"

Rake::Task["sidekiq:stop"].clear_actions
Rake::Task["sidekiq:start"].clear_actions
Rake::Task["sidekiq:restart"].clear_actions
namespace :sidekiq do
  task :stop do
    on roles(:app) do
      execute :sudo, :systemctl, :stop, :sidekiq
    end
  end
  task :start do
    on roles(:app) do
      execute :sudo, :systemctl, :start, :sidekiq
    end
  end
  task :restart do
    on roles(:app) do
      execute :sudo, :systemctl, :restart, :sidekiq
    end
  end
end

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

  after :publishing, :restart
  after :publishing, :fix_permissions

  set :rollbar_token, '75d79ff8ca4643809de5616d7c6c2265'
  set :rollbar_env, Proc.new { fetch :stage }
  set :rollbar_role, Proc.new { :app }
end

require './config/boot'
