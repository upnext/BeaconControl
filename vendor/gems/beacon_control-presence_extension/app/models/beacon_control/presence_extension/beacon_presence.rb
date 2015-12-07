###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module PresenceExtension

    #
    # Stores information about user's presence in Beacon range.
    #
    class BeaconPresence < ActiveRecord::Base
      scope :for_user,   ->(client_id) { where(client_id: client_id) }
      scope :for_beacon, ->(beacon_id) { where(beacon_id: beacon_id) }

      scope :for_ids, ->(ids) { for_beacon(ids) }

      scope :present, -> { where(present: true) }

      scope :for_user_and_beacon, ->(client_id, beacon_id) do
        for_user(client_id).for_beacon(beacon_id)
      end

      #
      # Checks if given timestamp is valid as enter beacon range timestamp.
      #
      def valid_timestamp_for_enter?(event_timestamp)
        (timestamp.nil? || Time.at(event_timestamp) > Time.at(timestamp.to_i))
      end

      #
      # Checks if given timestamp is valid as leave beacon range timestamp.
      #
      def valid_timestamp_for_leave?(event_timestamp)
        persisted? && event_timestamp.present? && Time.at(event_timestamp) > Time.at(timestamp)
      end
    end
  end
end
