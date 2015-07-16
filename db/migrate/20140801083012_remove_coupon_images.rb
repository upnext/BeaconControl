###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class RemoveCouponImages < ActiveRecord::Migration
  def up
    remove_column :coupons, :image
    remove_column :coupons, :logo
  end

  def down
    add_column :coupons, :image, :string
    add_column :coupons, :logo,  :string
  end
end
