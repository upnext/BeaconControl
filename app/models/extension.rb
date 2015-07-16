###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

#
# Generic extension class, wrapping all additional/external extension into unified objects.
#
class Extension
  include Virtus.model

  attribute :name, String
  attribute :extension_class

  #
  # Returns list of all Application objects having extension enabled.
  #
  def applications
    Application.joins(:application_extensions).where({
      application_extensions: { extension_name: name }
    })
  end

  #
  # Returns list of all Account objects having extension enabled.
  #
  def accounts
    Account.joins(:account_extensions).where({
      account_extensions: { extension_name: name }
    })
  end

  def to_s
    name
  end

  def to_partial_path
    'extensions/extension'
  end

  #
  # Publishes event to be processed by Extension, if it defines Worker class in own namespace.
  #
  # ==== Parameters
  #
  # * +event+        - Event object to be published
  # * +worker_class+ - Class of worker used to process event
  #
  def publish(event, worker_class = nil)
    worker_class ||= extension_worker

    return if extension_class.blank? || !Object.const_defined?(extension_worker)

    worker_class.to_s.constantize.new(event).publish
  end

  #
  # Returns Extension configuration options from initializer.
  #
  def config
    extension_class.config
  end

  def sidebar_links
    config.registers[:sidebar_links]
  end

  def setting_link
    config.setting_link
  end

  def actions
    config.registers[:actions]
  end

  def settings
    config.registers[:settings]
  end

  def configurations
    config.registers[:configurations].presence
  end

  def triggers
    config.registers[:triggers]
  end

  private

  #
  # Extension Worker class.
  #
  def extension_worker # :doc:
    "#{extension_class}::Worker"
  end

  def extension_worker_class
    extension_worker_class.constantize
  end
end
