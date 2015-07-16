###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateBeaconAssignments < ActiveRecord::Migration
  def change
    create_table :ext_kontakt_io_beacon_assignments do |t|
      t.references :beacon, null: false, index: true
      t.string :unique_id, null: false
    end
  end
end
