module BeaconControl
  module KontaktIoExtension
    class MappingService
      # @param [Admin] current_admin
      def initialize(current_admin)
        @admin = current_admin
      end

      # @param [Hash<String, Array<String>>] params
      def sync!(params)
        ActiveRecord::Base.transaction do
          sync_venues!(params)
          sync_beacons!(params)
        end
      end

      # @param [Hash<String, Array<String>>] params
      def sync_venues!(params)
        fetch_options!(params)
        venues.each do |data|
          next unless data.name.present?
          zone = get_zone(data)
          if zone.kontakt_io_mapping.blank?
            zone.build_kontakt_io_mapping(kontakt_uid: data.id)
          end
          update_zone!(zone, data) if update?
          if !data.db? || update?
            zone.account = admin.account
            zone.save
          end
        end
      end

      # @param [Hash<String, Array<String>>] params
      def sync_beacons!(params)
        fetch_options!(params)
        beacons.map do |data|
          beacon = get_beacon(data)
          update_beacon!(beacon, data) if update?
          if beacon.kontakt_io_mapping.blank?
            beacon.build_kontakt_io_mapping(kontakt_uid: data.unique_id)
          end
          if !data.db? || update?
            begin
              beacon.save!
            rescue StandardError => error
              raise error
            end
            assign_to_zone!(data, beacon)
          end
          beacon
        end
      end

      # private
      attr_reader :admin, :selected_beacons, :selected_venues

      # @param [::KontaktIo::Resource::Zone] data
      # @return [::Zone]
      def get_zone(data)
        find_zone(data) || build_zone(data)
      end

      # @param [::KontaktIo::Resource::Zone] data
      # @return [::Zone]
      def find_zone(data)
        ::Zone.kontakt_io.merge(KontaktIoMapping.with_uid(data.id)).where(account_id: admin.account_id).first
      end

      # @param [::KontaktIo::Resource::Zone] data
      # @return [::Zone]
      def build_zone(data)
        ::Zone.new(
          name: data.name,
          description: data.description
        )
      end

      def update_zone!(zone, kontakt_venue)
        zone.update_attributes(
          name: kontakt_venue.name,
          description: kontakt_venue.description
        )
      end

      # @param [KontaktIo::Resource::Beacon] kontakt_beacon
      # @return [::Beacon]
      def get_beacon(kontakt_beacon)
        find_beacon(kontakt_beacon) || build_beacon(kontakt_beacon)
      end

      # @param [KontaktIo::Resource::Beacon] kontakt_beacon
      # @return [::Beacon]
      def find_beacon(kontakt_beacon)
        ::Beacon.kontakt_io.merge(KontaktIoMapping.with_uid(kontakt_beacon.unique_id)).where(account_id: admin.account_id).first
      end

      # @param [KontaktIo::Resource::Beacon] kontakt_beacon
      # @return [::Beacon]
      def build_beacon(kontakt_beacon)
        ::Beacon::Factory.new(
          admin,
          name:  "#{kontakt_beacon.name} #{kontakt_beacon.unique_id}",
          uuid:  kontakt_beacon.proximity,
          major: kontakt_beacon.major,
          minor: kontakt_beacon.minor,
          instance: kontakt_beacon.instance_id,
          namespace: kontakt_beacon.namespace,
          url: kontakt_beacon.url,
          vendor: 'Kontakt',
          protocol: (kontakt_beacon.eddystone? ? 'Eddystone' : 'iBeacon')
        ).build
      end

      def update_beacon!(beacon, kontakt_beacon)
        Beacon::Factory.sorted_params(
          uuid:  kontakt_beacon.proximity,
          major: kontakt_beacon.major,
          minor: kontakt_beacon.minor,
          instance: kontakt_beacon.instance_id,
          namespace: kontakt_beacon.namespace,
          url: kontakt_beacon.url,
          vendor: 'Kontakt',
          protocol: (kontakt_beacon.eddystone? ? 'Eddystone' : 'iBeacon')
        ).each_pair { |k, v| beacon.send("#{k}=", v) }
      end

      # @return [Array<KontaktIo::Resource::Beacon>]
      def beacons
        @beacons ||= api.beacons.select do |beacon|
          beacon.was_imported = beacon_imported?(beacon.unique_id)
          return true if selected_beacons.nil?
          selected_beacons.include?(beacon.unique_id)
        end
      end

      # @return [Array<KontaktIo::Resource::Venue>]
      def venues
        @venues ||= load_venues
      end

      def load_venues
        if selected_beacons.any? && !venue_force_update?
          beacons.map do |beacon|
            beacon.venue
          end.compact.uniq(&:id).each do |venue|
            venue.was_imported = zone_mapped_uids.include?(venue.id)
          end
        elsif venue_force_update?
          api.venues.select do |venue|
            imported_venue_uids.include? venue.id
          end
        else
          api.venues.select do |venue|
            venue.was_imported = zone_mapped_uids.include?(venue.id)
            selected_venues.nil? ? selected_venues.include?(venue.id) : true
          end
        end
      end

      def imported_venue_uids
        @imported_venue_uids ||= imported_zones.map(&:kontakt_uid).compact
      end

      def imported_zones
        @imported_zones ||= admin.account.zones.kontakt_io
      end

      # @return [Array<String>]
      def zone_mapped_uids
        @zone_mapped_uids ||= KontaktIoMapping.zones.pluck(:kontakt_uid)
      end

      # @return [Array<String>]
      def beacon_mapped_uids
        @beacon_mapped_uids ||= KontaktIoMapping.beacons.pluck(:kontakt_uid)
      end

      # @return [KontaktIo::ApiClient]
      def api
        @api ||= KontaktIo::ApiClient.new(KontaktIo::ApiClient.account_api_key(admin.account))
      end

      def fetch_options!(params)
        @selected_beacons = params.fetch(:beacons, []) unless @selected_beacons
        @selected_venues  = params.fetch(:venues, []) unless @selected_venues
        @venue = params.fetch(:venue, false)
        @reassign = params.fetch(:reassign, false)
        @update = params[:update] == true
      end

      # @return [TrueClass|FalseClass]
      def update?
        @update
      end

      def venue_force_update?
        @venue.to_s == 'force_update'
      end

      # @param [String] uid
      # @return [TrueClass|FalseClass]
      def beacon_imported?(uid)
        beacon_mapped_uids.include?(uid)
      end

      # @param [String] uid
      # @return [TrueClass|FalseClass]
      def zone_imported?(uid)
        zone_mapped_uids.include?(uid)
      end

      def reassign?
        @reassign
      end

      def assign_to_zone!(data, beacon)
        return unless data.venue.present?
        return unless data.venue.id.present?
        return if beacon.zone.present? and !reassign?
        zone = Zone.with_kontakt_uid(data.venue.id).first
        zone.beacons << beacon if zone
      end
    end
  end
end