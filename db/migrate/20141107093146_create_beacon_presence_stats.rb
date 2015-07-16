###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateBeaconPresenceStats < ActiveRecord::Migration
  def change
    create_table :beacon_presence_stats do |t|
      t.string  :proximity_id,        null: false
      t.date    :date,                null: false
      t.integer :hour,                null: false
      t.integer :users_count,         default: 0
    end
  end
end
