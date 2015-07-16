###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module PresenceExtension
    class RangeLocationStorage

      #
      # Returns list of all users being currently in given beacons ranges.
      #
      # ==== Parameters
      #
      # * +range_ids+ - Array, list of Beacon IDs for which users should be returned.
      #
      def self.users_in_ranges(range_ids)
        StorageFinder.new(range_ids).find_for(BeaconPresence, :beacon_id, :client_id)
      end

      def initialize(event)
        self.beacon_id = event.range_id
        self.client_id = event.client_id
        self.timestamp = Time.at(event.timestamp).utc
      end

      #
      # Creates/updates beacon presence record in database for given user with enter information
      # and enter occurrence timestamp.
      #
      def enter
        bp = presence.first_or_create

        if bp.valid_timestamp_for_enter?(timestamp)
          bp.update_attributes(timestamp: timestamp, present: true)
        end
      end

      #
      # Updates beacon presence record in database with leave information and leave occurrence timestamp.
      #
      def leave
        bp = presence.first || BeaconPresence.new

        if bp.valid_timestamp_for_leave?(timestamp)
          bp.update_attributes(timestamp: timestamp, present: false)
        end
      end

      private

      attr_accessor :beacon_id, :client_id, :timestamp

      def presence
        BeaconPresence.for_user_and_beacon(client_id, beacon_id)
      end
    end
  end
end
