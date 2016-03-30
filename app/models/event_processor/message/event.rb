###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module EventProcessor
  class Message

    #
    # Represents API incoming event.
    #
    class Event
      include Virtus.model
      attribute :application,  Application

      # General attributes
      attribute :mobile_device, MobileDevice
      attribute :user,          User
      attribute :event_type,    String
      attribute :timestamp,     Integer, default: Time.now.to_i

      # Localization Attributes
      attribute :proximity_id, String
      attribute :range_id,     Integer
      attribute :zone_id,      Integer

      attribute :beacon,       Beacon
      attribute :zone,         Zone

      # Action attributes
      attribute :action_id,    Integer
      attribute :action,       Activity

      attribute :data,         Hash

      def data=(value)
        super(value.is_a?(String) ? JSON.parse(value) : value)
      end

      def with_range?
        range_id.present?
      end

      def with_zone?
        zone_id.present?
      end

      def with_proximity_id?
        proximity_id.present?
      end

      def with_action?
        action.present?
      end

      def with_event_type?
        event_type.present?
      end

      def client_id
        user.client_id
      end

      def ==(ev)
        [
          event_type   == ev.event_type,
          action_id    == ev.action_id,
          range_id     == ev.range_id,
          proximity_id == ev.proximity_id,
          user         == ev.user,
          action       == ev.action,
          timestamp    == ev.timestamp
        ].all?
      end
    end
  end
end
