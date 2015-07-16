###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class RemoveBeaconAndZoneIdFromTriggers < ActiveRecord::Migration
  def up
    Trigger.all.each do |trigger|
      trigger.beacon_ids = [trigger.beacon_id]
      trigger.zone_ids = [trigger.zone_id]
      trigger.save
    end

    remove_column :triggers, :beacon_id
    remove_column :triggers, :zone_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
