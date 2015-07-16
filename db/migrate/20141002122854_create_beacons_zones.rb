###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateBeaconsZones < ActiveRecord::Migration
  def change
    create_table :beacons_zones do |t|
      t.references :beacon
      t.references :zone
    end
    add_foreign_key :beacons_zones, :beacons
    add_foreign_key :beacons_zones, :zones
  end
end
