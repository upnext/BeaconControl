###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateExtensions < ActiveRecord::Migration
  def change
    create_table :extensions do |t|
      t.string :name
      t.integer :kind

      t.timestamps null: false
    end
  end
end
