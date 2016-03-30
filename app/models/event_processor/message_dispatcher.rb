###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module EventProcessor
  class MessageDispatcher
    attr_reader :user, :mobile_device, :events, :application

    def initialize(message)
      self.user          = message.user
      self.mobile_device = message.mobile_device
      self.application   = message.application
      self.events        = message.events.map {|e| prepare_for_dispatch(e) }
    end

    #
    # Parses received message into list of events, and for each of them requests further processing
    # by all of application's enabled extensions.
    #
    def dispatch
      logger.debug "Application: #{application.inspect}"
      logger.debug "Enabled extensions: #{enabled_extensions.map(&:name).join(', ')}"

      events.each do |event|
        logger.debug "Processing event: #{event.inspect}"

        action = Activity.find_by(id: event.action_id)
        if action.present?
          event.action     = action
          event.event_type = action.trigger.event_type

          logger.info "Event is related to action (#{action.id})"
        else
          logger.info "Event is generic"
        end

        beacon = if event.with_range?
                   Beacon.find_by(id: event.range_id)
                 elsif event.with_proximity_id?
                   Beacon.find_by_proximity_id(event.proximity_id)
                 end

        zone = if event.with_zone?
                 Zone.find_by(id: event.zone_id)
               end

        if beacon.present?
          event.beacon       = beacon
          event.range_id     = beacon.id
          event.proximity_id = beacon.proximity_id.to_s
          logger.info "Event is related to beacon: #{beacon.name} (#{beacon.proximity_id})"
        elsif zone.present?
          event.zone         = zone
          event.zone_id      = zone.id
          logger.info "Event is related to zone: #{zone.name} (#{zone.id})"
        else
          logger.error "Couldn't match an appropriate beacon or zone for event #{event.inspect}. Skipping this event."
          next
        end

        logger.info "No extension instances found" if enabled_extensions.empty?

        EventProcessor::EventDispatcher.new(
          event:      event,
          extensions: enabled_extensions,
        ).dispatch

        true
      end
    end

    private

    attr_writer :user, :mobile_device, :events, :application

    def prepare_for_dispatch(event)
      event.user          = user
      event.mobile_device = mobile_device
      event.application   = application
      event
    end

    def enabled_extensions
      @enabled_extensions ||= application.active_extensions
    end

    def logger
      Sidekiq.logger
    end
  end
end
