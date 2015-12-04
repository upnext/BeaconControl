###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module PresenceExtension
    class ZoneLocationStorage

      #
      # Returns list of all users being currently in given zones.
      #
      # ==== Parameters
      #
      # * +zone_ids+ - Array, list of Zone IDs for which users should be returned.
      #
      def self.users_in_zones(zone_ids)
        StorageFinder.new(zone_ids).find_for(ZonePresence, :zone_id, :client_id)
      end

      def initialize(event)
        self.zone_id   = event.zone_id
        self.client_id = event.client_id
        self.timestamp = Time.at(event.timestamp).utc
      end

      #
      # Creates/updates zone presence record in database for given user with enter information
      # and enter occurrence timestamp.
      #
      def enter
        BeaconPresence.transaction do
          ZonePresence.present.for_user(client_id).update_all(present: false)
          zp = presence.first_or_create(present: false)
          if zp.valid_timestamp_for_enter?(timestamp)
            zp.update_attributes(timestamp: timestamp, present: true)
          end
        end
      end

      #
      # Updates zone presence record in database with leave information and leave occurrence timestamp.
      #
      def leave
        BeaconPresence.transaction do
          zp = presence.first_or_create(present: false)
          if zp.valid_timestamp_for_leave?(timestamp)
            zp.update_attributes(timestamp: timestamp, present: false)
          end
        end
      end

      private

      attr_accessor :zone_id, :client_id, :timestamp

      def presence
        ZonePresence.for_user_and_zone(client_id, zone_id)
      end
    end
  end
end
