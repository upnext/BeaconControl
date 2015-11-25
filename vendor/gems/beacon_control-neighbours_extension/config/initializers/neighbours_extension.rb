require 'sprockets/es6'

BeaconControl::NeighboursExtension.configure do |config|
  #
  # Register extension link on application extensions list
  #
  config.setting_link = ->(*) do
    beacon_control_neighbours_extension.application_neighbours_path(@application)
  end

  #
  # Register link in global sidebar
  # Icon: font-awesome icon class
  #
  # config.register :sidebar_links, {
  #   i18n_key: 'neighbours_extension.sidebar_links.neighbours',
  #   path: Proc.new{ beacon_control_neighbours_extension.root_path },
  #   icon: 'info'
  # }

  #
  # Register custom activity link in application action page
  #
  # config.register :actions, {
  #   i18n_key: 'activities.form.scheme.neighbours',
  #   scheme: 'neighbours',
  #   permitted_attributes: { neighbours_attributes: [:id, :name, :_destroy] }
  # }

  #
  # Register new Action Trigger type
  #
  # config.register :triggers, {
  #   key: :neighbours,
  #   permitted_attributes: [:neighbours]
  # }

  #
  # Register custom setting on application edit page
  # Type: setting value type, availiable types: :string, :password, :text, :file
  #
  # config.register :settings, {
  #   i18n_key: 'neighbours_extension.settings.neighbours',
  #   key: :neighbours,
  #   type: :string,
  #   validations: Proc.new{ { presence: true, length: { minimum: 3, maximum: 6 } } }
  # }

  #
  # Register global extension configuration setting on after-activation page.
  #
  # config.register :configurations, {
  #   i18n_key: 'neighbours_extension.configurations.neighbours_setting',
  #   key: :neighbours_setting
  # }

  #
  # Configures extension as autoloadable on Account creation
  #
  # config.autoloadable = true
end
