###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateTriggers < ActiveRecord::Migration
  def change
    create_table :triggers do |t|
      t.string :name
      t.belongs_to :beacon, index: true

      t.timestamps null: false
    end
  end
end
