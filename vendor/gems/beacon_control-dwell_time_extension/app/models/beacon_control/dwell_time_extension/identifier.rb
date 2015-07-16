###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module DwellTimeExtension
    class Identifier
      def initialize(event, trigger_id)
        self.event      = event
        self.trigger_id = trigger_id
      end

      #
      # Creates unique identifier for given event and trigger to use as job ID in redis.
      #
      def to_s
        id_for(sha1)
      end

      private

      attr_accessor :event, :trigger_id

      def id_for(identifier)
        "#{BeaconControl::DwellTimeExtension.table_name_prefix}#{identifier}"
      end

      def sha1
        Digest::SHA1.hexdigest(json)
      end

      def json
        attributes.to_json
      end

      def attributes
        {
          mobile_device_id: event.mobile_device.id,
          proximity_id:     event.proximity_id,
          trigger_id:       trigger_id
        }
      end
    end
  end
end
