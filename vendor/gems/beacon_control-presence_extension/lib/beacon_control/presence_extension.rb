###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require "beacon_control/presence_extension/engine" if defined?(Rails)
require "beacon_control/presence_extension/version"

module BeaconControl
  module PresenceExtension
    include BeaconControl::Base::Extension

    self.registered_name = "Presence"

    register_extension! "beacon_control-presence_extension"

    def self.table_name_prefix
      "ext_presence_"
    end

    def self.load_files
      [
        "app/workers/beacon_control/presence_extension/worker"
      ]
    end
  end
end
