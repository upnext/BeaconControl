###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateBeaconPresences < ActiveRecord::Migration
  def change
    create_table :ext_presence_beacon_presences do |t|
      t.integer :beacon_id
      t.string  :client_id

      t.datetime :timestamp
      t.boolean  :present, default: false

      t.timestamps null: false
    end
  end
end
