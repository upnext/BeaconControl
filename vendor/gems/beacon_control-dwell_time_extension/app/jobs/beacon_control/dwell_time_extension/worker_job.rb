###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module DwellTimeExtension

    #
    # ActiveJob subclass, configures jobs queuing and implements execution.
    # Used to process incoming API events.
    #
    class WorkerJob < BeaconControl::BaseJob

      queue_as :extension_event

      def perform(event)
        message_event = EventProcessor::Message::Event.new(event)

        logger.debug "Received event #{message_event.inspect}"

        case message_event.event_type
        when 'enter' then EnterEvent.new(message_event).call
        when 'leave' then LeaveEvent.new(message_event).call
        else logger.info "Unsupported event_type: #{message_event.event_type}"
        end
      end
    end
  end
end
