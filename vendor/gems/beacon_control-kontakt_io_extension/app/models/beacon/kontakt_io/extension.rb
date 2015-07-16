###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'beacon' unless defined? Beacon

class Beacon
  module KontaktIo
    module Extension
      extend ActiveSupport::Concern
      included do
        has_one :beacon_assignment, class_name: BeaconControl::KontaktIoExtension::BeaconAssignment, dependent: :destroy

        delegate :unique_id, to: :beacon_assignment, allow_nil: true
      end
    end
  end
end

Beacon.send :include, Beacon::KontaktIo::Extension