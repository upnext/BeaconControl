###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree.
###

module S2sApi
  module V1
    class KontaktIoBeaconSerializer < BaseSerializer
      attributes :device, :beacon_status, :beacon_firmware, :config
      attributes :uuid

      def uuid
        object.uuid
      end

      def device
        object.device.attributes if object.device
      end

      def beacon_status
        object.beacon_status.attributes if object.beacon_status
      end

      def beacon_firmware
        object.beacon_firmware.attributes if object.beacon_firmware
      end

      def config
        object.config.attributes if object.config
      end
    end
  end
end
