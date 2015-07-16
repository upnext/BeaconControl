###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateTriggersSources < ActiveRecord::Migration
  def change
    create_table :triggers_sources do |t|
      t.references :trigger,     null: false
      t.integer    :source_id,   null: false
      t.string     :source_type, null: false
    end
  end
end
