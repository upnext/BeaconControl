###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class UpdateModelRelations < ActiveRecord::Migration
  def change
    remove_index    :applications, :admin_id
    remove_column   :applications, :admin_id
    add_reference   :applications, :account, index: true
    add_foreign_key :applications, :accounts

    remove_column   :beacons, :admin_id
    add_foreign_key :beacons, :accounts, name: "index_beacons_on_account_id"
  end
end
