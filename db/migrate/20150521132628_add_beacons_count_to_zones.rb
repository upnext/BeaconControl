###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class AddBeaconsCountToZones < ActiveRecord::Migration
  class Beacon < ActiveRecord::Base
    belongs_to :zone, counter_cache: true
  end

  class Zone < ActiveRecord::Base
    has_many :beacons
  end

  def change
    add_column :zones, :beacons_count, :integer

    reversible do |dir|
      dir.up do
        Zone.find_each do |z|
          Zone.reset_counters(z.id, :beacons)
        end
      end
    end
  end
end
