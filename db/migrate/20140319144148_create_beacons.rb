###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateBeacons < ActiveRecord::Migration
  def change
    create_table :beacons do |t|
      t.string :name
      t.string :proximity_id

      t.timestamps null: false
    end
    add_index :beacons, :proximity_id, unique: true
  end
end
