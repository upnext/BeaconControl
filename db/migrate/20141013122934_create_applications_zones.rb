###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateApplicationsZones < ActiveRecord::Migration
  def change
    create_table :applications_zones do |t|
      t.references :application
      t.references :zone
    end

    add_index :applications_zones,
      [:application_id, :zone_id],
      name: :applications_zones_index
  end
end
