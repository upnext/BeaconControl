###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Beacon < ActiveRecord::Base
  belongs_to :zone
end

class Zone < ActiveRecord::Base
end

class BeaconsZone < ActiveRecord::Base
  belongs_to :beacon
  belongs_to :zone
end

class ChangeZoneToBelongsToZone < ActiveRecord::Migration
  def change
    reversible do |dir|

      dir.up do
        add_column :beacons, :zone_id, :integer

        BeaconsZone.all.each do |bz|
          b = bz.beacon
          b.zone = bz.zone
          b.save
        end

        drop_table :beacons_zones
      end

      dir.down do
        create_table :beacons_zones do |t|
          t.references :beacon
          t.references :zone
        end

        add_foreign_key :beacons_zones, :beacons
        add_foreign_key :beacons_zones, :zones

        Beacon.all.each do |b|
          BeaconsZone.create(zone_id: b.zone_id, beacon_id: b.id) if b.zone_id
        end

        remove_column :beacons, :zone_id
      end
    end
  end
end
