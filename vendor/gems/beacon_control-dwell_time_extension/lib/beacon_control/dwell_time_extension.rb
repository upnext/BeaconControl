###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'beacon_control/dwell_time_extension/version'

module BeaconControl
  module DwellTimeExtension
    include BeaconControl::Base::Extension

    self.registered_name = 'DwellTime'

    register_extension! 'beacon_control-dwell_time_extension'

    def self.table_name_prefix
      'ext_dwell_time_'
    end

    def self.load_files
      [
        'app/workers/beacon_control/dwell_time_extension/worker'
      ]
    end

    auto_include('Beacon', 'DwellTime', 'Beacon::DwellTime')
    auto_include('Zone', 'DwellTime', 'Zone::DwellTime')
    auto_include('Trigger', 'DwellTimeExt', 'Trigger::DwellTimeExt')
    auto_include('S2sApi::V1::TriggerSerializer', 'DwellTime', '::S2sApi::V1::TriggerSerializer::DwellTime')
  end
end

require 'beacon_control/dwell_time_extension/engine' if defined?(Rails)
