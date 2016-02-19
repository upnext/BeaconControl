###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module PresenceExtension
    class Storage
      include BeaconControl::SidekiqLogger

      UnsupportedEventType = Class.new(StandardError)

      #
      # Gets information about all users being currently in given application zone(s)/beacon(s) ranges.
      #
      # ==== Parameters
      #
      # * +application+ - Application for which present users should be fetched.
      # * +params+      - Hash, valid keys:
      #   * +ranges+    - Array of beacons IDs. If not provided, all application beacons will be processed.
      #     If empty/nil, none of the application beacons will be processed. If present, only matching
      #     application beacons will be processed further.
      #   * +zones+     - Array of zones IDs. If not provided, all application zones will be processed.
      #     If empty/nil, none of the application zones will be processed. If present, only matching
      #     application zones will be processed further.
      #
      def self.get_status(application, params)
        ranges = load_ranges(application, params)
        zones  =  load_zones(application, params)

        Rails.logger.info "Getting status for ranges: #{ranges.inspect}, zones: #{zones.inspect}"

        {}.tap do |users|
          users[:ranges] = RangeLocationStorage.users_in_ranges(ranges) if ranges
          users[:zones]  = ZoneLocationStorage.users_in_zones(zones)    if zones

          Rails.logger.debug "Retrieved users: #{users.inspect}"
        end
      end

      def initialize(message_event)
        self.event = message_event
      end

      #
      # Saves enter/leave event message, depending on event type.
      #
      def save
        case event.event_type
          when 'enter' then enter
          when 'leave' then leave
          else logger.info "Unsupported event_type: #{event.event_type}"
        end
      end

      private

      def self.load_ranges(application, params)
        ::BeaconControl::PresenceExtension::BeaconPresence.where(
          'updated_at < :now', now: Time.now - AppConfig.presence_timeout
        ).update_all(present: false)
        if !params.has_key?(:ranges)
          application.beacons.pluck(:id)
        elsif params[:ranges].nil?
          nil
        else
          application.beacons.where(id: params[:ranges]).pluck(:id)
        end
      end

      def self.load_zones(application, params)
        ::BeaconControl::PresenceExtension::ZonePresence.where(
          'updated_at < :now', now: Time.now - AppConfig.presence_timeout
        ).update_all(present: false)
        if !params.has_key?(:zones)
          application.zones.pluck(:id)
        elsif params[:zones].nil?
          nil
        else
          application.zones.where(id: params[:zones]).pluck(:id)
        end
      end

      #
      # Checks if event is zone or beacon - related, and saves enter event message.
      #
      def enter # :doc:
        if event.with_range?
          RangeLocationStorage.new(event).enter
        elsif event.with_zone?
          ZoneLocationStorage.new(event).enter
        end
      end

      #
      # Checks if event is zone or beacon - related, and saves leave event message.
      #
      def leave # :doc:
        if event.with_range?
          RangeLocationStorage.new(event).leave
        elsif event.with_zone?
          ZoneLocationStorage.new(event).leave
        end
      end

      attr_accessor :event
    end
  end
end
