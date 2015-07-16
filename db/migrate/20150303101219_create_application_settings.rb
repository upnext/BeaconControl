###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateApplicationSettings < ActiveRecord::Migration
  def change
    create_table :application_settings do |t|
      t.references :application, null: false, index: true
      t.string :extension_name, null: false
      t.string :type, null: false
      t.string :key, null: false
      t.text :value

      t.timestamps null: false
    end
  end
end
