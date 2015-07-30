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
      attributes :id, :name, :proximity_id, :location, :zone

      def zone
        S2sApi::V1::ZoneWithoutBeaconsSerializer.new(object.zone, root: false).as_json if object.zone
      end

      def proximity_id
        object.proximity_id.to_s
      end

      def location
        {
          lat: object.lat,
          lng: object.lng,
          floor: object.floor,
          address: object.location
        }
      end
    end
  end
end
