###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class AddButtonFieldsToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :button_font_color, :string
    add_column :coupons, :button_background_color, :string
    add_column :coupons, :button_label, :string
    add_column :coupons, :button_link, :string
  end
end
