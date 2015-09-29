###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'beacon_config' unless defined? Beacon

class BeaconConfig
  module KontaktIoExtension
    module Extension
      extend ActiveSupport::Concern
      included do
        unless method_defined?(:_non_kontakt_io_load_data)
          alias_method :_non_kontakt_io_load_data, :load_data
          alias_method :_non_kontakt_io_update_data, :update_data
        end

        # @param [Admin] admin
        # @return [ActiveSupport::HashWithIndifferentAccess]
        def load_data(admin)
          hash = _non_kontakt_io_load_data(admin)
          if beacon && beacon.kontakt_io_mapping
            merge_kontakt_data(admin, hash)
          end
          hash
        end

        # Should send update request to kontakt io.
        # @public
        # @param [Admin] admin
        # @param [Hash] data
        def update_data(admin, data)
          if beacon && beacon.kontakt_uid.present?
            update_kontakt_beacon(admin, data)
          else
            _non_kontakt_io_update_data(admin, data)
          end
        end

        def update_kontakt_beacon(admin, data)
          load_data(admin)
          params = {
            txPower: data[:transmission_power],
            interval: data[:signal_interval],
            alias: beacon.name,
            lat: beacon.lat,
            lng: beacon.lng
          }
          api = KontaktIo::ApiClient::for_admin(admin)
          api.update_device(beacon.kontakt_uid, beacon.config.device_type, params)
        end

        def merge_kontakt_data(admin, hash)
          uid = beacon.kontakt_uid
          api = KontaktIo::ApiClient::for_admin(admin)
          device = api.device(uid).attributes.with_indifferent_access
          firmware = api.device_firmware(uid)
          config = api.device_config(uid).attributes.with_indifferent_access
          hash.merge!(device.except(:venue, :was_imported))
          hash.merge!(latest_firmware: firmware.latest?)
          hash.merge!(config: config.except(:was_imported))
          hash.merge!(device.fetch(:status, {}))
        end
      end
    end
  end
end
