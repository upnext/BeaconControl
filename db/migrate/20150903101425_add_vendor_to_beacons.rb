class AddVendorToBeacons < ActiveRecord::Migration
  def change
    add_column :beacons, :vendor, :string, default: 'Other'
  end
end
