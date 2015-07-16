###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module AnalyticsExtension
    class Aggregator
      def initialize(event)
        self.event = event
      end

      #
      # Stores event. If it's +leave+, aggregates with matching enter event into overall dwell time.
      #
      def aggregate
         create_event

        if event.event_type == "leave"
          aggregate_events
        end
      end

      private

      attr_accessor :event, :db_event

      #
      # Stores BeaconControl::AnalyticsExtension::Event object in database.
      #
      def create_event # :doc:
        self.db_event = Event.create!(
          application_id: event.application.id,
          proximity_id: event.proximity_id.to_s,
          event_type: event.event_type,
          user_id: event.client_id,
          timestamp: Time.at(event.timestamp),
          action_id: event.action_id
        )

        if event.with_zone?
          db_event.zones << event.zone
        else
          db_event.beacons << event.beacon
        end
      end

      #
      # Tries to find +enter+ Event for given matching event in database, only with
      # smaller timestamp. Result can be +nil+ (+leave+ could arrive before +enter+).
      #
      def matching_enter_event # :doc:
        @matching_enter_event ||= Event.
          where(event_data.merge(event_type: 'enter')).
          where('timestamp < ?', db_event.timestamp).
          order('timestamp desc').
          limit(1).
          first
      end

      #
      # Tries to find +leave+ Event for matching event in database.
      #
      def last_leave_event # :doc:
        @last_leave_event ||= Event.
          where(event_data.merge(event_type: 'leave')).
          where('timestamp < ?', db_event.timestamp).
          order('timestamp desc').
          limit(1).
          first
      end

      #
      # Creates DwellTimeAggregation for each day in range between +enter+ event and
      # last +leave+ event.
      #
      def aggregate_events # :doc:
        if matching_enter_event && (last_leave_event.blank? || last_leave_event.timestamp < matching_enter_event.timestamp)
          time_range = TimeRange.new(
            matching_enter_event.timestamp,
            db_event.timestamp
          ).split_to_days

          time_range.inject do |start_time, time|
            DwellTimeAggregation.create!(
              event_data.merge(
                date: Time.at(start_time).to_date,
                timestamp: Time.at(start_time),
                dwell_time: time - start_time
              )
            )

            time
          end
        end
      end

      def event_data
        {
          application_id: event.application.id,
          proximity_id:   event.proximity_id.to_s,
          user_id:        event.client_id
        }
      end
    end
  end
end
