###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module Extensions

  #
  # Keeps track of all added extensions, allows managing list of active extensions.
  #
  class Registry
    class RawExtensionModule < Struct.new(:registered_name)
    end

    ExtensionAlreadyRegistered = Class.new(StandardError)

    def initialize
      yield self if block_given?
    end

    #
    # Ruby Set of Extension instances to work on.
    #
    def registry_set
      @registry_set ||= Set.new
    end

    #
    # Adds extension to set, throws exteption if registered already.
    #
    # ==== Parameters
    #
    # * +ext+ - Extension to add to Registry. Only Modules are supported.
    #
    def add(ext)
      extension = if ext.kind_of? Module
                    ext
                  else
                    RawExtensionModule.new(ext.to_s)
                  end

      if registered?(extension.registered_name)
        raise ExtensionAlreadyRegistered.new(
          "Extension with name #{extension.name} already registered"
        )
      end

      Extension.new(
        name: extension.registered_name,
        extension_class: extension
      ).tap do |ext|
        registry_set << ext
      end
    end

    #
    # Removes Extension from set by name.
    #
    # ==== Parameters
    #
    # * +ext_name+ - String, name of extension to remove from Registry.
    #
    def remove(ext_name)
      registry_set.delete_if {|ext| ext.name == ext_name.to_s }
    end

    #
    # Clear whole Registry to empty set.
    #
    def clear
      @registry_set = Set.new
    end

    #
    # Returns subset of extensions in Registry, not present in passed extensions list.
    #
    # ==== Parameters
    #
    # * +object_extensions+ - Array, list of extensions which should NOT be included in returned set
    #
    def inactive_extensions_for(object_extensions)
      active_extensions = object_extensions.select(&:persisted?).map(&:extension_name)

      registry_set.select do |ext|
        !active_extensions.include?(ext.name)
      end
    end

    #
    # Returns subset of extensions in Registry, present in passed extensions list.
    #
    #
    # ==== Parameters
    #
    # * +object_extensions+ - Array, list of extensions which should be included in returned set
    #
    def active_extensions_for(object_extensions)
      active_extensions = object_extensions.select(&:persisted?).map(&:extension_name)

      registry_set.select do |ext|
        active_extensions.include?(ext.name)
      end
    end

    #
    # Finds Extension in Registry by its name.
    #
    # ==== Parameters
    #
    # * +name+ - String, name of Extension
    #
    def find(name)
      registry_set.find {|ext| ext.name == name }
    end

    #
    # Returns Array of all registered extension's custom actions schemes.
    #
    def extensions_schemes
      registry_set.map do |ext|
        next unless ext.respond_to?(:actions)
        ext.actions.map { |act| act[:scheme] }
      end.compact.flatten
    end

    #
    # Returns Hash to be used as +permitted_attributes+ for extra fields in application action(Activity) form,
    # added by registered extension custom actions.
    #
    def extensions_actions_permitted_attributes
      registry_set.map{ |ext| ext.actions }.flatten.inject({}) { |h,k|
        k[:permitted_attributes] || {}
      }
    end

    #
    # Returns Array to be added as +permitted_attributes+ to Trigger extra fields in application action(Activity) form,
    # added by registered extension custom Trigger type.
    #
    def extensions_trigger_permitted_attributes
      registry_set.map{ |ext| ext.triggers }.flatten.inject([]) { |_,trigger|
        trigger[:permitted_attributes] || []
      }
    end

    #
    # Returns Array of autoloadable extensions
    #
    def autoloadable
      registry_set.select{ |ext| ext.config.autoloadable && AppConfig.autoload_extensions[ext.name] }
    end

    private

    #
    # Checks if extension is added to set.
    #
    # ==== Parameters
    #
    # * +name+ - String, name of extension to check
    #
    def registered?(name) # :doc:
      registered_names.include?(name)
    end

    #
    # Returns list of names of extensions added to set.
    #
    def registered_names # :doc:
      registry_set.map(&:name)
    end
  end
end
