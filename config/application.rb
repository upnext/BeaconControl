###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative 'app_config'
require_relative 'version'

module BeaconControl
  EXTENSIONS = []

  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    initializer 'extentions.configure', before: :load_config_initializers do
      BeaconControl::Base.prepare_extensions! do |ext|
        true
      end
    end

    initializer 'extensions.load_dependencies', after: :load_config_initializers do
      BeaconControl::Base.load_extensions! do |ext|
        # ext.registered_name != 'DwellTime'
        true
      end
    end

    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    if AppConfig.landing_page_url
      config.middleware.insert_before 0, "Rack::Cors" do
        allow do
          origins AppConfig.landing_page_url
          resource '*', :headers => :any, :methods => [:get, :post, :options]
        end
      end
    end
  end
end
