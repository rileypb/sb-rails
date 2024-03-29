require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SbRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.middleware.insert_before 0, Rack::Cors do 
    	allow do
    		origins '*'
    		resource '*', :headers => :any, :methods => [:get, :post, :patch, :options, :delete]
    	end
    end

    config.send_active_users = ENV['SB_ACTIVE_USERS'] == 'true'
    config.strict_order_checking = ENV['SB_CHECK_ORDER'] == 'true'
  end
end
