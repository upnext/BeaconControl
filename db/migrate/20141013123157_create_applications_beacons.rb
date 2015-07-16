###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateApplicationsBeacons < ActiveRecord::Migration
  def change
    create_table :applications_beacons do |t|
      t.references :application
      t.references :beacon
    end

    add_index :applications_beacons,
      [:application_id, :beacon_id],
      name: :applications_beacons_index
  end
end
