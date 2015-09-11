class WrappedBeacon < SimpleDelegator
  def initialize(beacon, admin)
    super(beacon)
    @beacon = beacon
    @admin = admin
  end
  def beacon_status
  end

  def beacon_firmware
  end

  def uuid
  end

  def device
  end

  def battery_level
  end

  def config
  end

  def cloud?
  end

  def master
  end

  def master_beacon
  end

  def interval
  end

  def tx_power
  end

  attr_reader :beacon, :admin
end