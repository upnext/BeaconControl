###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class AddTypeToTriggers < ActiveRecord::Migration
  class Trigger < ActiveRecord::Base
  end

  def change
    add_column :triggers, :type, :string
    Trigger.update_all type: "BeaconTrigger"
  end
end
