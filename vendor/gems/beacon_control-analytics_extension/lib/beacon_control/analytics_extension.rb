###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require "beacon_control/analytics_extension/engine" if defined?(Rails)
require "beacon_control/analytics_extension/version"

module BeaconControl
  module AnalyticsExtension
    include BeaconControl::Base::Extension

    register_extension! "beacon_control-analytics_extension"

    self.registered_name = "Analytics"

    def self.table_name_prefix
      "ext_analytics_"
    end

    def self.load_files
      [
        "app/workers/beacon_control/analytics_extension/worker"
      ]
    end
  end
end
