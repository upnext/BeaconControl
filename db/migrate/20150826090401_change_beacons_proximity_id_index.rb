class ChangeBeaconsProximityIdIndex < ActiveRecord::Migration
  def change
    remove_index :beacons, :proximity_id
    add_index :beacons, [:proximity_id, :account_id], unique: true
  end
end
