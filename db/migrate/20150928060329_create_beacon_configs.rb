class CreateBeaconConfigs < ActiveRecord::Migration
  def change
    create_table :beacon_configs do |t|
      t.belongs_to :beacon, index: true
      t.string :data

      t.datetime :beacon_updated_at

      t.timestamps null: false
    end
    add_foreign_key :beacon_configs, :beacons
  end
end
