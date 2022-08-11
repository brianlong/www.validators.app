# frozen_string_literal: true

require_relative 'boot'
require 'kaminari'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FmaRubyOnRailsTemplate
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Load all of the sub-folders in `app/`
    config.autoloader = :classic

    # Load blacklist of validators from config/validator_blacklist.yml
    config.validator_blacklist = config_for(:validator_blacklist)

    # Settings in config/environments/* take precedence over those specified
    # here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
