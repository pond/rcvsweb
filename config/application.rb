require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Rcvsweb
  class Application < Rails::Application

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.load_defaults 5.2

    # Allow multiple Rails applications by giving the session cookie a
    # unique prefix. In this application the ApplicationController class
    # turns sessions off (at the time of writing, 22-Aug-2006) anyway,
    # but in future sessions may be used again in which case the line
    # below will be important.
    #
    config.session_store :cookie_store, key: 'rcvswebapp_session_id'

  end
end
