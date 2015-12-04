###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateZonePresences < ActiveRecord::Migration
  def change
    create_table :ext_presence_zone_presences do |t|
      t.integer :zone_id
      t.string  :client_id

      t.datetime :timestamp
      t.boolean  :present, default: false

      t.timestamps null: false
    end
  end
end
