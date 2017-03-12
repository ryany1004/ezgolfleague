source 'https://rubygems.org'

ruby '2.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'devise', '~> 3.5.6'
gem 'devise_invitable', '~> 1.5.2'
gem 'pretender'

gem 'bootstrap-sass', '~> 3.3.4'
gem "paperclip", "~> 5.0.0"
gem 'aws-sdk', '~> 2.3'
gem 'kaminari', '~> 0.17'
gem 'simple_form'
gem 'momentjs-rails', '~> 2.9',  :github => 'derekprior/momentjs-rails'
gem 'datetimepicker-rails', github: 'zpaulovics/datetimepicker-rails', branch: 'master', submodules: true
gem 'chosen-rails'
gem 'smarter_csv'
gem 'airbrake', '~> 5.0'
gem 'nokogiri'
gem 'attr_encrypted', '1.3.5'
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'
gem 'delayed_job_active_record'
gem 'progress_job'
gem 'backport_new_renderer', :github => 'brainopia/backport_new_renderer'
gem 'apnotic'
gem 'geocoder'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

group :development, :test do
  gem 'sqlite3', :require => "sqlite3"

  gem "rspec-rails", "3.5.0.beta3"
  gem 'factory_girl_rails'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'derailed'

  gem "bullet"
  gem 'rack-mini-profiler', require: false
end

group :test do
  gem "capybara", "2.7.1"
end

group :production do
  gem 'pg', '~> 0.17.1'
  gem 'rails_12factor'
  gem 'dalli'
  gem 'puma'
  gem 'puma_worker_killer'
  # gem 'newrelic_rpm'
  gem 'scout_apm'
end
