class RemoveBeaconsCountFromZones < ActiveRecord::Migration
  class Beacon < ActiveRecord::Base
    belongs_to :zone, counter_cache: true
  end

  class Zone < ActiveRecord::Base
    has_many :beacons
  end

  def change
    reversible do |dir|
      dir.up do
        remove_column :zones, :beacons_count
      end

      dir.down do
        add_column :zones, :beacons_count, :integer
        Zone.find_each do |z|
          Zone.reset_counters(z.id, :beacons)
        end
      end
    end
  end
end
