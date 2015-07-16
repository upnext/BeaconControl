###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module ExtensionData
  # Responsible for serializing application's zones & ranges for Presence extension
  # into JSON format, to send via API.
  class Presence
    def initialize(application)
      self.application = application
    end

    def as_json
      {
        extensions: {
          presence: {
            zones: application.zone_ids,
            ranges: application.beacon_ids
          }
        },
        zones: zones,
        ranges: ranges
      }
    end

    attr_accessor :application

    private

    def zone_range_ids
      Beacon.where(zone_id: application.zone_ids)
    end

    def ranges
      serialized_collection(
        Beacon.where(id: (zone_range_ids | application.beacon_ids).compact)
      )
    end

    def zones
      serialized_collection(application.zones.includes(:beacons))
    end

    def serialized_collection(collection)
      ActiveModel::ArraySerializer.new(collection).as_json
    end
  end
end
