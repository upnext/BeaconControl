###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateCouponImages < ActiveRecord::Migration
  def change
    create_table :coupon_images do |t|
      t.references :coupon, index: true
      t.string :file
      t.string :type

      t.timestamps null: false
    end
  end
end
