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
      def index
        render 'index',
               locals: {
                 beacons: beacons,
                 zones: Zone.kontakt_io.order('created_at DESC')
               }
      end

      def beacons
        current_admin.account.beacons.kontakt_io.order('created_at DESC').each do |beacon|
          config = beacon.beacon_config || beacon.build_beacon_config
          config.load_data current_admin
        end
      end

      #
      # Fetch & display list of Kontakt.io beacons with division on new and present in DB.
      #
      def import
        render 'import',
               locals: {
                 beacons: beacons_manager.to_import(api_client.beacons),
                 sync: false
               }
      end

      #
      # Stores new beacons in DB, creates assignment Beacon Control <-> KontaktIO beacon.
      #
      def create
        sync!(params)
        redirect_to beacon_control_kontakt_io_extension.beacons_path
      end

      def sync
        sync!(
          params.merge(
            update: true,
            beacons: current_admin.account.beacons.kontakt_io.order('created_at DESC')
          )
        )
        beacons = current_admin.account.beacons.kontakt_io.order('created_at DESC').pluck(:kontakt_uid)
        render 'sync',
               locals: {
                 beacons: beacons_manager.to_import(api_client.beacons).select do |b|
                   beacons.include?(b.unique_id)
                 end,
                 sync: true
               }
      end

      private

      def sync!(params)
        ::BeaconControl::KontaktIoExtension::MappingService.
          new(current_admin).
          sync!(params)
      end

      def api_client
        @api_client ||= KontaktIo::ApiClient.for_admin(current_admin)
      end

      def beacons_manager
        @beacons_manager ||= BeaconsManager.new(current_admin)
      end
    end
  end
end
