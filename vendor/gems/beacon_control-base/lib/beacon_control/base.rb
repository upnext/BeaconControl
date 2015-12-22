###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require "active_support/all"
require "beacon_control/eventable"
require "beacon_control/base/version"
require "beacon_control/base/config"
require "beacon_control/base/extension"
require "beacon_control/base/generators/extension_generator"

module BeaconControl
  module Base
    #
    # Defines list of files to require, forcing eager loading and paths not included in default load paths.
    #
    def self.load_files
      [
        "app/controllers/beacon_control/application_controller",
        "app/controllers/beacon_control/api/v1/base_controller",
        "app/controllers/beacon_control/admin_controller",
        "app/jobs/beacon_control/sidekiq_logger",
        "app/jobs/beacon_control/base_job"
      ]
    end

    # Load all required files
    # e.q. all meta-programming modules
    #
    # @example:
    #     # <example_extension_root>/app/models/activity/example_extension.rb
    #     require 'activity' unless defined? Activity
    #
    #     class Activity
    #       module ExampleExtension
    #         extend ActiveSupport::Concern
    #         included do
    #           has_many :examples
    #         end
    #       end
    #     end
    #     Activity.send :include, Activity::ExampleExtension
    #
    # @yield [ext] enabling extension block, if return false extension will not be loaded
    # @yieldparam [BeaconControl::Base::Extension] ext the extension that is yielded
    # @yieldreturn [TrueClass|FalseClass] module should me enabled
    def self.load_extensions!(&block)
      extensions.each do |(gem_name, ext)|
        if ext == ::BeaconControl::Base || block.nil? || block.call(ext)
          ext.load_files.each do |f|
            root = Gem::Specification.find_by_name(gem_name).gem_dir
            require_relative File.join(root, f)
          end
        end
      end
    end

    # Prepare extension by:
    # * add extension to extensions enabled extensions list
    # * add extension routes to application router
    #
    # @yield [ext] enabling extension block, if return false extension will not be loaded
    # @yieldparam [BeaconControl::Base::Extension] ext the extension that is yielded
    # @yieldreturn [TrueClass|FalseClass] module should me enabled
    def self.prepare_extensions!(&block)
      extensions.each_value do |ext|
        next if ext == BeaconControl::Base
        next unless block.nil? || block.call(ext)
        next if BeaconControl::EXTENSIONS.include?(ext)
        BeaconControl::EXTENSIONS << ext

        Rails.application.routes.append do
          mount ext::Engine => '/'
        end rescue nil
      end
    end

    def self.exec_load
      BeaconControl::Base.watch_reload.each_pair do |klass, reload_hash|
        Rails.logger.info "exec load auto inject #{klass}"
        klass = klass.constantize
        reload_hash.each_pair do |identity, injections|
          Rails.logger.info "  checking appearance of #{identity}"
          unless klass.const_defined?(identity)
            Rails.logger.info "    not found!"
            injections.each do |mod|
              Rails.logger.info "  including #{mod}"
              klass.send(:include, mod.constantize)
            end
          end
        end
      end
    end

    # @return [Hash]
    def self.extensions
      @extensions ||= {}
    end

    def self.watch_reload
      @watch_reload ||= {}
    end

    # @param [String] gem_name
    # @param [BeaconControl::Base::Extension] base_class
    def self.register_extension(gem_name, base_class)
      return if extensions.has_key? gem_name
      extensions[gem_name] = base_class
    end
    include Extension
    auto_include('ApplicationController', 'ParamsExtendable', 'ApplicationController::ParamsExtendable')
    auto_include('Ability', 'ExtensionManageable', 'Ability::ExtensionManageable')
  end
end

require "beacon_control/base/railtie" if defined?(Rails::Railtie)
