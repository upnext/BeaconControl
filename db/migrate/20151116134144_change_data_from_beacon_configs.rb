class ChangeDataFromBeaconConfigs < ActiveRecord::Migration
  def change
    change_column :beacon_configs, :data, :text
  end
end
