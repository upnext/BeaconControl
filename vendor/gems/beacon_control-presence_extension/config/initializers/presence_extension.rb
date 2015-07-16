###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

BeaconControl::PresenceExtension.configure do |config|
  #
  # Register extension link on application extensions list
  #
  config.setting_link = Proc.new{ beacon_control_presence_extension.application_presence_path(application_id: @application.id) }

  #
  # Register link in global sidebar
  # Icon: font-awesome icon class
  #
  # config.register :sidebar_links, {
  #   i18n_key: 'presence_extension.sidebar_links.presence',
  #   path: Proc.new{ beacon_control_presence_extension.root_path },
  #   icon: 'info'
  # }

  #
  # Register custom activity link in application action page
  #
  # config.register :actions, {
  #   i18n_key: 'activities.form.scheme.presence',
  #   scheme: 'presence',
  #   permitted_attributes: { presences_attributes: [:id, :name, :_destroy] }
  # }

  #
  # Register new Action Trigger type
  #
  # config.register :triggers, {
  #   key: :presence,
  #   permitted_attributes: [:presence]
  # }

  #
  # Register custom setting on application edit page
  # Type: setting value type, availiable types: :string, :password, :text, :file
  #
  # config.register :settings, {
  #   i18n_key: 'presence_extension.settings.presence',
  #   key: :presence,
  #   type: :string,
  #   validations: Proc.new{ { presence: true, length: { minimum: 3, maximum: 6 } } }
  # }

  #
  # Register global extension configuration setting on after-activation page.
  #
  # config.register :configurations, {
  #   i18n_key: 'presence_extension.configurations.api_key',
  #   key: :api_key
  # }

  #
  # Configures extension as autoloadable on Account creation
  #
  config.autoloadable = true
end
