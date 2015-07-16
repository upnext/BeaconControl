###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateMobileDevices < ActiveRecord::Migration
  def change
    create_table :mobile_devices do |t|
      t.belongs_to :user, index: true
      t.text       :push_token,   limit: 63.kilobytes
      t.integer    :os,           null: false
      t.integer    :environment,  null: false, default: 1
      t.boolean    :active,       default: true, null: false, index: true
      t.datetime   :last_sign_in_at

      t.timestamps null: false
    end

    add_foreign_key :mobile_devices, :users
  end
end
