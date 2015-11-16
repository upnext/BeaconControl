###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module S2sApi
  module V1
    class BeaconSerializer < BaseSerializer
      attributes :id, :name, :proximity_id, :location, :zone, :vendor, :protocol, :unique_id, :config

      def zone
        S2sApi::V1::ZoneWithoutBeaconsSerializer.new(object.zone, root: false).as_json if object.zone
      end

      def proximity_id
        case object.protocol
        when 'iBeacon'
          object.proximity_id.i_beacon.join("+")
        when 'Eddystone'
          object.proximity_id.eddystone.join("+")
        else
          object.proximity_id.to_s
        end
      end

      def location
        {
          lat: object.lat,
          lng: object.lng,
          floor: object.floor,
          address: object.location
        }
      end

      def unique_id
        object.vendor_uid
      end

      def config
        {
          data: object.config.attributes,
          config_updated_at: object.beacon_config.updated_at,
          beacon_updated_at: object.beacon_config.beacon_updated_at
        }
      end
    end
  end
end
