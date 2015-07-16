###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module ZonesHelper
  def beacon_select_options(beacons)
    beacons.map do |b|
      [b.name, b.id, {data: {group: b.manager_id.to_s}}]
    end
  end
end