###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class BeaconSerializer < ApplicationSerializer
  attributes :id, :name, :proximity_id, :location, :vendor, :protocol, :config, :unique_id

  def proximity_id
    case object.protocol
    when 'iBeacon'
      object.proximity_id.i_beacon.join('+')
    when 'Eddystone'
      object.proximity_id.eddystone.join('+')
    else
      object.proximity_id.to_s
    end
  end

  def unique_id
    object.vendor_uid
  end

  def location
    {
      lat: object.lat,
      lng: object.lng,
      floor: object.floor
    }
  end

  def config
    object.config.attributes
  end
end
