###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateExtensionSettings < ActiveRecord::Migration
  def change
    create_table :extension_settings do |t|
      t.references :account,    null: false
      t.string :extension_name, null: false
      t.string :key,            null: false
      t.string :value
    end
  end
end
