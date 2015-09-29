class KontaktIoBeacon < WrappedBeacon
  def beacon_status
    @beacon_status ||= api.device_status(uuid)
  rescue KontaktIo::Error::NotFound
    @beacon_status = ::KontaktIo::Resource::Status.new(
      battery_level: 'Unknown',
      last_event_timestamp: 0,
      avg_event_interval: 0,
      master: ''
    )
  end

  def beacon_firmware
    @beacon_firmware ||= api.device_firmware(uuid)
  rescue KontaktIo::Error::NotFound
    @beacon_firmware = ::KontaktIo::Resource::Firmware.new({})
  end

  def uuid
    beacon.kontakt_io_mapping.kontakt_uid if kontakt?
  end

  def device
    @device ||= api.device(uuid)
  rescue KontaktIo::Error::NotFound
    @device = ::KontaktIo::Resource::Device.new({})
  end

  def battery_level
    beacon_status.battery_level if beacon_status
  end

  def config
    @config ||= api.device_config( uuid )
  rescue KontaktIo::Error::NotFound
    @device = ::KontaktIo::Resource::Config.new({})
  end

  def cloud?
    device.device_type.to_s.upcase == 'BEACON_CLOUD'
  end

  def master
    beacon_status.master
  end

  def master_beacon
    @master_beacon ||= ::Beacon.kontakt_io.merge(
      ::KontaktIoMapping.with_uid(master)
    ).where(
       account_id: beacon.account_id
    ).first
  end

  def interval
    device.interval if device
  end

  def tx_power
    device.tx_power if device
  end

  # private
  attr_reader :beacon, :admin

  def api
    @api ||= KontaktIo::ApiClient.new(
      KontaktIo::ApiClient.account_api_key(admin.account)
    )
  end

  def kontakt?
    beacon.kontakt_io_mapping
  end
end