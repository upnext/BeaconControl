module KontaktIo
  module Resource
    class Device < Base
      attribute :id,                  String
      attribute :unique_id,           String
      attribute :device_type,         String
      attribute :specification,       String
      attribute :name,                String
      attribute :alias,               String
      attribute :interval,            Integer
      attribute :tx_power,            Integer
      attribute :manager_id,          String
      attribute :venue,               Object
      attribute :browser_actions,     Array
      attribute :content_actions,     Array
      attribute :actions_count,       Integer
      attribute :default_ssid_crypt,  String
      attribute :default_ssid_name,   String
      attribute :default_ssid_key,    String
      attribute :default_ssid_auth,   String
      attribute :wifi_scan_interval,  Integer
      attribute :data_send_interval,  Integer
      attribute :ble_scan_interval,   Integer
      attribute :ble_scan_duration,   Integer
      attribute :wifi_scan_count,     Integer
      attribute :working_mode,        String
      attribute :firmware,            String
      attribute :access,              String
      attribute :shares,              Array
      attribute :maintenance_start,   String
      attribute :maintenance_end,     String
      attribute :maintenance_enabled, Boolean
      attribute :metadata,            Hash
      attribute :hashing_policy,      String
      attribute :status,              Hash
      attribute :lat,                 Integer
      attribute :lng,                 Integer
      attribute :created,             String
      attribute :updated,             String

      attribute :import,              Boolean
      attribute :profiles,            Array

      attribute :proximity,           String
      attribute :major,               Integer
      attribute :minor,               Integer

      attribute :instance_id,         String
      attribute :namespace,           String
      attribute :url,                 String

      def eddystone?
        profiles.include?('EDDYSTONE')
      end

      def ibeacon?
        profiles.include?('IBEACON')
      end

      def profile
        profiles.first
      end

      def profiles=(val)
        val = [] unless val.is_a?(Array)
        super(val.map(&:upcase))
      end

      def status=(hash)
        if hash.is_a?(Hash)
          hash = ::KontaktIo::Resource::Status.new(hash)
        end
        super hash
      end

      # Composes +ProximityId+ string representation of Beacon +uuid,major,minor+ fields.
      # @return [String]
      def proximity_id
        if eddystone?
          "#{self.proximity}##{self.instance_id}##{self.namespace}##{self.url}".upcase
        else
          "#{proximity}+#{major}+#{minor}".upcase
        end
      end

      #
      # Compares +KontaktIo::Resource::Beacon+ with AR Beacon based on:
      #   * +unique_id+ field from Kontakt.io, or
      #   * +proximity,major,minor+ fields compacted to +proximity_id+
      #
      # ==== Parameters
      #
      # +* +db_beacon+ - Beacon from database to compare with
      #
      def ==(db_beacon)
        unique_id == db_beacon.unique_id ||
          proximity_id.to_s == db_beacon.proximity_id.to_s
      end

      def venue=(value)
        super(value.is_a?(KontaktIo::Resource::Venue) ? value : KontaktIo::Resource::Venue.new(value || {}))
      end
    end
  end
end