###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module EventProcessor

  #
  # Represents whole message received by events API. Contains:
  # * +events+        - Array of Message::Events in message
  # * +user+          - User which sent message
  # * +application+   - user's Application
  # * +mobile_device+ - user's MobileDevice
  #
  class Message
    include Virtus.model

    attribute :events, Array[Message::Event]
    attribute :user
    attribute :mobile_device
    attribute :application

    def valid?
      [user, mobile_device, events, application].all?(&:present?)
    end
  end
end
