class BeaconConfig < ActiveRecord::Base
  belongs_to :beacon
  serialize :data, ActiveSupport::HashWithIndifferentAccess

  DEFAULT_DATA_KEYS = [
    :battery_level,
    :device_id,
    :last_action,
    :average_connection_interval,
    :latest_firmware,
    :signal_interval,
    :transmission_power,
    :master,
    :slaves
  ]

  after_initialize :ensure_data

  # Update beacon configuration.
  # Some extension can override this functionality or add some custom stuff.
  # @param [Admin] admin
  # @param [Hash] data
  def update_data(admin, data)
    loaded_data.merge!(data.with_indifferent_access)
    update_attribute(:data, loaded_data)
  end

  # Loading beacon configuration.
  # Some extension can override this functionality or add some custom stuff.
  # @param [Admin] admin
  # @return [ActiveSupport::HashWithIndifferentAccess]
  def load_data(admin)
    @loaded_data ||= self.data.with_indifferent_access
  end

  # Preloaded data. This method require to call BeaconConfig#load_data before use.
  def loaded_data
    @loaded_data ||= data
  end

  # Initialize data.
  private def ensure_data
    self.data ||= {}
    DEFAULT_DATA_KEYS.each do |key|
      self.data.key?(key) || self.data.merge!(key => nil)
    end
  end
end
