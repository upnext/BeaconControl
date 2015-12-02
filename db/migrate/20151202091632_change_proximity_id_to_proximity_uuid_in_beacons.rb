class ChangeProximityIdToProximityUuidInBeacons < ActiveRecord::Migration
  def change
    remove_index :beacons, [:proximity_id, :account_id]
    remove_column :beacons, :proximity_id
    add_column :beacons, :proximity_uuid, :string
    add_index :beacons, [:proximity_uuid, :account_id], unique: true
  end
end
