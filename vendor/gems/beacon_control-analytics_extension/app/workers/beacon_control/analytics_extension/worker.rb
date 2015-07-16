###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module AnalyticsExtension
    class Worker
      def initialize(event_data)
        self.message_event = EventProcessor::Message::Event.new(event_data)
      end

      def publish
        Aggregator.new(message_event).aggregate
      end

      private

      attr_accessor :message_event
    end
  end
end
