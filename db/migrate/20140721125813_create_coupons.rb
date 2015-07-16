###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :template
      t.string :name
      t.string :title
      t.text :description
      t.string :logo
      t.string :image
      t.references :activity, index: true

      t.timestamps null: false
    end
    add_index :coupons, :template
  end
end
