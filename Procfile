web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -e production -c 10 -v -q ezgolfleague_production_mailers -q rollbar -q default