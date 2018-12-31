source 'https://rubygems.org'

ruby '2.3.4'

gem 'rails', '5.1.6'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jbuilder'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'devise',           '~> 4.2'
gem 'devise_invitable', '~> 1.7.0'
gem 'pretender'
gem 'bootstrap-sass', '~> 3.3.4'
gem 'paperclip', '~> 5.0.0'
gem 'aws-sdk', '~> 2.3'
gem 'kaminari'
gem 'simple_form'
gem 'momentjs-rails', '~> 2.9', github: 'derekprior/momentjs-rails'
gem 'datetimepicker-rails', github: 'zpaulovics/datetimepicker-rails', branch: 'master', submodules: true
gem 'chosen-rails'
gem 'nokogiri'
gem 'attr_encrypted', '~> 3.0.0'
gem 'stripe', git: 'https://github.com/stripe/stripe-ruby'
gem 'redis-rails'
gem 'resque'
gem 'resque-scheduler'
gem 'resque-retry'
gem 'resque-web', require: 'resque_web'
gem 'daemons'
gem 'apnotic'
gem 'geocoder'
gem 'fcm'
gem 'marginalia'
gem 'capistrano', '3.3.5'
gem 'capistrano3-delayed-job', '~> 1.0'
gem 'capistrano-rails', '~> 1.1'
gem 'capistrano-bundler', '~> 1.1.3'
gem "capistrano-resque", "~> 0.2.2", require: false
gem 'rollbar'
gem 'acts_as_paranoid', '~> 0.6.0'
gem 'drip-ruby', require: 'drip'

group :development do
  gem 'web-console'
end

group :development, :test do
  gem 'sqlite3', require: 'sqlite3'
  gem 'rspec-rails', '3.5.0.beta3'
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
