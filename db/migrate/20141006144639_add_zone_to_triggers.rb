###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class AddZoneToTriggers < ActiveRecord::Migration
  def change
    add_reference :triggers, :zone, index: true
  end
end
