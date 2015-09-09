module KontaktIo
  module Resource
    class Device < Base
      attribute :id,                String
      attribute :unique_id,          String
      attribute :device_type,        String
      attribute :specification,     String
      attribute :proximity,         String
      attribute :major,             Integer
      attribute :minor,             Integer
      attribute :name,              String
      attribute :alias,             String
      attribute :interval,          Integer
      attribute :tx_power,           Integer
      attribute :manager_id,         String
      attribute :venue,             Hash
      attribute :browser_actions,    Array
      attribute :content_actions,    Array
      attribute :actions_count,      Integer
      attribute :default_ssid_crypt,  String
      attribute :default_ssid_name,   String
      attribute :default_ssid_key,    String
      attribute :default_ssid_auth,   String
      attribute :wifi_scan_interval,  Integer
      attribute :data_send_interval,  Integer
      attribute :ble_scan_interval,   Integer
      attribute :ble_scan_duration,   Integer
      attribute :wifi_scan_count,     Integer
      attribute :working_mode,       String
      attribute :firmware,          String
      attribute :access,            String
      attribute :shares,            Array
      attribute :maintenance_start,  String
      attribute :maintenance_end,    String
      attribute :metadata,          Hash
      attribute :hashing_policy,     String
      attribute :status,            Hash
      attribute :lat,               Integer
      attribute :lng,               Integer
      attribute :created,           String
      attribute :updated,           String
    end
  end
end