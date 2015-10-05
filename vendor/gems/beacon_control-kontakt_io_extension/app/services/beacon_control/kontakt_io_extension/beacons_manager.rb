###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module KontaktIoExtension
    class BeaconsManager
      def initialize(current_admin)
        @current_admin = current_admin
      end

      #
      # Partition list of beacons from Kontakt.io into already existing in
      # Beacon Control DB and new beacons.
      #
      # ==== Parameters
      #
      # * +kontakt_beacons+ - Array, list of KontaktIo::Resource::Beacon objects
      #   built based on API response.
      #
      #
      def to_import(kontakt_beacons)
        kontakt_beacons.map do |kontakt_beacon|
          kontakt_beacon.was_imported = beacon_imported?(kontakt_beacon)
          kontakt_beacon
        end.sort_by do |kontakt_beacon|
          kontakt_beacon.db? ? 1 : 0
        end
      end

      #
      # Imports beacons to DB:
      # * For beacons already present, creates +BeaconAssignment+ association
      #   between Kontakt.io beacon and Beacon Control beacon
      # * For new beacons, stores them in DB if user chose them to (based on +import+ flag)
      #
      # ==== Parameters
      #
      # * +kontakt_beacons+ - Array, list of KontaktIo::Resource::Beacon objects with following data:
      #   * +in_db+  - Boolean, if matching beacon was already found in DB
      #   * +import+ - Boolean, should NEW beacon be imported
      #   * +proximity,unique_id,name,major,minor+ - Beacon specific data
      #
      def import(kontakt_beacons)
        kontakt_beacons.each do |kontakt_beacon|
          if kontakt_beacon.in_db
            db_beacon = beacon_from_db(kontakt_beacon)
          else
            if kontakt_beacon.import
              db_beacon = build_beacon(kontakt_beacon)
            else
              next
            end
          end

          db_beacon.build_beacon_assignment(
            unique_id: kontakt_beacon.unique_id
          ) unless db_beacon.beacon_assignment

          db_beacon.save
        end
      end

      #
      # Synchronizes Kontakt.io beacons with matching beacons in Beacon Control database.
      # Creates +BeaconAssignment+ if not found, updates beacon fields otherwise.
      # Returns list of processed records.
      #
      # ==== Parameters
      #
      # * +kontakt_beacons+ - Array, list of KontaktIo::Resource::Beacon objects fetched from API.
      #
      def sync(kontakt_beacons)
        kontakt_beacons.select do |kontakt_beacon|
          db_beacon = beacon_from_db(kontakt_beacon)
          if db_beacon
            if db_beacon.beacon_assignment
              db_beacon.assign_attributes(
                uuid:  kontakt_beacon.proximity,
                major: kontakt_beacon.major,
                minor: kontakt_beacon.minor
              )
            else
              db_beacon.build_beacon_assignment(
                unique_id: kontakt_beacon.unique_id
              )
            end

            db_beacon.save
          end
        end
      end

      private

      def db_beacons
        @db_beacons ||= @current_admin.account.beacons.includes(:beacon_assignment)
      end

      #
      # Finds first matching beacon from database based on existing BeaconAssignment
      # or proximity match.
      #
      # ==== Parameters
      #
      # * +kontakt_beacon+ - KontaktIo::Resource::Beacon object to match against
      #
      def beacon_imported?(kontakt_beacon)
        imported_beacon_uids.include?(kontakt_beacon.unique_id)
      end

      def imported_beacon_uids
        @imported_beacon_uids ||= KontaktIoMapping.beacons.pluck(:kontakt_uid)
      end

      #
      # Builds new Beacon Control Beacon AR object based on imported Kontakt.io beacon.
      #
      # ==== Parameters
      #
      # * +kontakt_beacon+ - KontaktIo::Resource::Beacon instance to take
      #   attributes from
      #
      def build_beacon(kontakt_beacon)
        Beacon::Factory.new(
          @current_admin,
          name:  "[#{kontakt_beacon.unique_id}] #{kontakt_beacon.name}",
          uuid:  kontakt_beacon.proximity,
          major: kontakt_beacon.major,
          minor: kontakt_beacon.minor
        ).build
      end
    end
  end
end
