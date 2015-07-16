###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateEventExtensions < ActiveRecord::Migration
  def change
    create_table :event_extensions do |t|
      t.string :name, unique: true

      t.timestamps null: false
    end
  end
end
