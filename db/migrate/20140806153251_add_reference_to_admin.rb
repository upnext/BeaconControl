###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class AddReferenceToAdmin < ActiveRecord::Migration
  def change
    add_column :admins, :account_id, :integer
    add_index :admins, :account_id
    add_foreign_key :admins, :accounts
  end
end
