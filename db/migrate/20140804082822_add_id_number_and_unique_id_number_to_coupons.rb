###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class AddIdNumberAndUniqueIdNumberToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :identifier_number,        :string
    add_column :coupons, :unique_identifier_number, :string
    add_column :coupons, :encoding_type,            :integer, default: nil

    add_index :coupons, :unique_identifier_number, unique: true
  end
end
