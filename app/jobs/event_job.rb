###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class EventJob < BeaconControl::BaseJob

  queue_as :event

  def perform(message)
    ep_message = EventProcessor::Message.new(message)

    if ep_message.valid?
      EventProcessor::MessageDispatcher.new(ep_message).dispatch
    else
      logger.info "Payload is not a valid batch object"
    end
  end
end
