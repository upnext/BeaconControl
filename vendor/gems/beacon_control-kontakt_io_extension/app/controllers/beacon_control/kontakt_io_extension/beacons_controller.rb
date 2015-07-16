###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module KontaktIoExtension
    class BeaconsController < BeaconControl::AdminController

      #
      # Fetch & display list of Kontakt.io beacons with division on new and present in DB.
      #
      def import
        @beacons = beacons_manager.to_import api_client.beacons
      end

      #
      # Stores new beacons in DB, creates assignment Beacon Control <-> KontaktIO beacon.
      #
      def create
        beacons = import_params[:beacons].map{ |b|
          KontaktIo::Resource::Beacon.new(b)
        }
        BeaconsManager.new(current_admin).import beacons

        redirect_to beacon_control_kontakt_io_extension.beacons_path
      end

      def sync
        @beacons = beacons_manager.sync api_client.beacons
      end

      private

      def api_client
        @api_client ||= KontaktIo::ApiClient.new(
          KontaktIo::ApiClient.account_api_key(current_account)
        )
      end

      def beacons_manager
        @beacons_manager ||= BeaconsManager.new(current_admin)
      end

      def import_params
        params.permit(:beacons => [:unique_id, :proximity, :name, :major, :minor, :import, :in_db])
      end
    end
  end
end
