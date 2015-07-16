###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module ExtensionData

  #
  # Responsible for serializing application's triggers into JSON format, to send via API.
  #
  class Triggers
    def initialize(application)
      self.application = application
      self.range_ids = []
      self.zone_ids = []
    end

    def as_json
      application.triggers.includes(:beacons, :zones).each do |trigger|
        range_ids.push *trigger.beacon_ids
        zone_ids.push *trigger.zone_ids
      end

      {
        extensions: {},
        triggers: triggers,
        ranges: ranges,
        zones: zones,
        ttl: 86400
      }
    end

    private

    def zone_range_ids
      Beacon.where(zone_id: application.zone_ids)
    end

    def ranges
      serialized_collection(
        Beacon.where(id: (zone_range_ids | range_ids).compact)
      )
    end

    def zones
      serialized_collection(
        Zone.where(id: zone_ids.uniq.compact)
      )
    end

    def triggers
      serialized_collection(application.triggers.includes(:beacons, :zones, activity: :custom_attributes))
    end

    def serialized_collection(collection)
      ActiveModel::ArraySerializer.new(collection).as_json
    end

    attr_accessor :application, :range_ids, :zone_ids
  end
end
