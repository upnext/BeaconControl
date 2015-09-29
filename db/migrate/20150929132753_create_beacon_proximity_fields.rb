class CreateBeaconProximityFields < ActiveRecord::Migration
  def up
    create_table :beacon_proximity_fields do |t|
      t.string :name
      t.string :value
      t.belongs_to :beacon, index: true

      t.timestamps null: false
    end
    add_foreign_key :beacon_proximity_fields, :beacons
    Beacon.all.each do |beacon|
      beacon.proximity_id
    end
  end

  def down
    drop_table :beacon_proximity_fields
  end
end
