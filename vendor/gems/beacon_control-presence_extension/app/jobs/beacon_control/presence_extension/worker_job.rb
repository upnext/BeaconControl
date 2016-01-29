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
    # ActiveJob subclass, configures jobs queuing and implements execution.
    # Used to process incoming API events.
    #
    class WorkerJob < BeaconControl::BaseJob
      queue_as :extension_event

      def perform(event)
        message_event = EventProcessor::Message::Event.new(event)

        logger.debug "Received event #{message_event.inspect}"

        ::BeaconControl::PresenceExtension::Storage.new(message_event).save
      end
    end
  end
end
