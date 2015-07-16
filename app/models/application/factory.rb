###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Application

  #
  # Factory for Application model.
  #
  class Factory
    delegate :errors, to: :application

    #
    # Initializer
    #
    # ==== Parameters
    #
    # * +admin+  - Admin model object, for which application should be created for
    # * +params+ - application parameters. Valid keys: +:name+, +:application_settings_attributes+
    #
    def initialize(admin, params)
      self.application = Application.new(params.merge account: admin.account)
      self.account = admin.account
    end

    def create
      application.tap do |app|
        if app.save
          create_doorkeeper_app
          prepare_test_app if app.test
        end
      end
    end

    private

    attr_accessor :application, :account

    def create_doorkeeper_app
      doorkeeper_app = Doorkeeper::Application.new(
        name: application.name, redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
      )
      doorkeeper_app.owner = application
      doorkeeper_app.save!
    end

    #
    # Setup test application: activate all autoloadable extensions for application and account
    #
    def prepare_test_app
      ExtensionsRegistry.autoloadable.each do |extension|
        account.activate_extension(extension)
        application.activate_extension(extension)
      end

      load_sandbox_cert
      load_production_cert
    end

    def load_sandbox_cert
      if AppConfig.sandbox_cert_path && File.file?(AppConfig.sandbox_cert_path)
        rpush_app = RpushApnsApp.new(
          cert_p12: File.open(AppConfig.sandbox_cert_path),
          environment: 'sandbox',
          application: application,
          passphrase: AppConfig.sandbox_cert_passphrase
        ).app

        application.apns_app_sandbox = rpush_app if rpush_app.valid?
      end
    end

    def load_production_cert
      if AppConfig.production_cert_path && File.file?(AppConfig.production_cert_path)
        rpush_app = RpushApnsApp.new(
          cert_p12: File.open(AppConfig.production_cert_path),
          environment: 'production',
          application: application,
          passphrase: AppConfig.production_cert_passphrase
        ).app

        application.apns_app_production = rpush_app if rpush_app.valid?
      end
    end
  end
end
