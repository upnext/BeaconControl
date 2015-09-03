class AddProtocolToBeacons < ActiveRecord::Migration
  def change
    add_column :beacons, :protocol, :string, default: 'iBeacon'
  end
end
