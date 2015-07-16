###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class AddOwnerToApplication < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :owner_id, :integer, :null => true
    add_column :oauth_applications, :owner_type, :string, :null => true
    add_index :oauth_applications, [:owner_id, :owner_type]
  end
end
