###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require "beacon_control/kontakt_io_extension/engine" if defined?(Rails)
require "beacon_control/kontakt_io_extension/version"

module BeaconControl
  module KontaktIoExtension
    include BeaconControl::Base::Extension

    register_extension! "beacon_control-kontakt_io_extension"

    self.registered_name = "Kontakt.io"

    def self.table_name_prefix
      "ext_kontakt_io_"
    end

    def self.load_files
      [
        "lib/kontakt_io/api_client",
        "lib/kontakt_io/error",
        "lib/kontakt_io/resource"
      ]
    end

    auto_include('Beacon', 'KontaktIoExtension', 'Beacon::KontaktIoExtension::Extension')
    auto_include('ProximityId', 'KontaktIoExtension', 'ProximityId::KontaktIoExtension::Extension')
    auto_include('Beacon::ConfigObject', 'KontaktIoExtension', 'Beacon::KontaktIoExtension::ConfigObject')
    auto_include('BeaconConfig', 'KontaktIoExtension', 'BeaconConfig::KontaktIoExtension::Extension')
    auto_include('Zone', 'KontaktIoExtension', 'Zone::KontaktIoExtension::Extension')
    auto_include('BeaconsController', 'KontaktIoExtension', 'BeaconControl::BeaconsController::KontaktIoExtension')
    auto_include('S2sApi::V1::BeaconsController', 'S2sBeaconsExtension', 'BeaconControl::KontaktIoExtension::S2sBeaconsExtension')
    auto_include('BeaconIdentityValidator', 'KontaktIoExtension', 'BeaconIdentityValidator::KontaktIoExtension::Validator')
  end
end
