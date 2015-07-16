###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateEventExtensionAssignments < ActiveRecord::Migration
  def change
    create_table :event_extension_assignments do |t|
      t.references :event_extension, index: true
      t.references :application, index: true
      t.text :configuration

      t.timestamps null: false
    end
  end
end
