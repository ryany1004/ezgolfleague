source 'https://rubygems.org'

ruby '2.3.4'

gem 'rails', '5.1'
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
gem 'airbrake', '~> 5.0'
gem 'nokogiri'
gem 'attr_encrypted', '~> 3.0.0'
gem 'stripe', git: 'https://github.com/stripe/stripe-ruby'
gem 'delayed_job_active_record'
gem 'delayed_job_web'
gem 'progress_job', github: 'HunterHillegas/progress_job'
gem 'apnotic'
gem 'geocoder'
gem 'fcm'
gem 'marginalia'

group :development do
  gem 'web-console'
end

group :development, :test do
  gem 'sqlite3', require: 'sqlite3'
  gem 'rspec-rails', '3.5.0.beta3'
  gem 'factory_girl_rails'
  gem 'byebug'
  gem 'spring'
  gem 'derailed'
  gem 'bullet'
  gem 'rack-mini-profiler', require: false
end

group :test do
  gem 'capybara', '2.7.1'
end

group :production do
  gem 'pg'
  gem 'dalli'
  gem 'puma'
  gem 'puma_worker_killer'
  gem 'scout_apm'
end
