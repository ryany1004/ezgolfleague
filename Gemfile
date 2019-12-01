source 'https://rubygems.org'

ruby '2.5.3'

gem 'acts_as_paranoid', '~> 0.6.0'
gem 'apnotic'
gem 'attr_encrypted', '~> 3.0.0'
gem 'aws-sdk', '~> 2.3'
gem 'bcrypt_pbkdf'
gem 'bootstrap', '~> 4.2.1'
gem 'bootstrap-select-rails'
gem 'capistrano', '3.9.0'
gem 'capistrano-bundler', '~> 1.1.3'
gem 'capistrano-rails', '~> 1.1'
gem 'capistrano-resque', '~> 0.2.2', require: false
gem 'capistrano3-delayed-job', '~> 1.0'
gem 'chosen-rails'
gem 'coffee-rails'
gem 'daemons'
gem 'devise',           '~> 4.2'
gem 'devise_invitable', '~> 1.7.0'
gem 'drip-ruby', require: 'drip'
gem 'ed25519'
gem 'fcm'
gem 'geocoder'
gem 'jb'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'kaminari'
gem 'marginalia'
gem 'momentjs-rails', '~> 2.9', github: 'derekprior/momentjs-rails'
gem 'nokogiri'
gem 'paperclip', '~> 5.0.0'
gem 'pretender'
gem 'rails', '5.2.3'
gem 'redis-rails'
gem 'rollbar'
gem 'sass-rails', '~> 5.0'
gem 'scout_apm'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'selectize-rails'
gem 'sidekiq', '5.2.7'
gem 'simple_form'
gem 'stripe', git: 'https://github.com/stripe/stripe-ruby'
gem 'uglifier', '>= 1.3.0'
gem 'webpacker'

group :development do
  gem 'capistrano-sidekiq', github: 'seuros/capistrano-sidekiq'
  gem 'faker'
  gem 'listen'
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'web-console'
end

group :development, :test do
  gem 'sqlite3', require: 'sqlite3'
  gem 'rspec-rails', '3.5.0'
  gem 'factory_bot_rails'
  gem 'byebug'
  gem 'spring'
  gem 'derailed'
  gem 'bullet'
  gem 'rack-mini-profiler', require: false
  gem 'flamegraph'
  gem 'stackprof'
end

group :test do
  gem 'capybara', '2.7.1'
end

group :production do
  gem 'pg'
  gem 'dalli'
end
