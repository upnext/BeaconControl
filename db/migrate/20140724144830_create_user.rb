###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateUser < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :client_id, null: false
    end
  end
end
