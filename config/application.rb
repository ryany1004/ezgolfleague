require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EzgolfRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.autoload_paths << Rails.root.join('lib')

    # Rails.autoloaders.log!

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.generators do |g|
      g.test_framework :rspec
    end

    config.action_dispatch.default_headers = {
      'X-Frame-Options' => 'ALLOWALL'
    }

    config.middleware.insert_after Rack::Sendfile, Rack::Deflater

    ActiveRecord::Base.include_root_in_json = false
  end
end
