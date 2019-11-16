web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -e production -c 15 -v -q ezgolfleague_production_mailers -q rollbar -q ezgolfleague_production_notifications -q default