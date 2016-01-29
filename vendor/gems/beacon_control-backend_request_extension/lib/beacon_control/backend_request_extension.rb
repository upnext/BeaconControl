require "beacon_control/backend_request_extension/engine" if defined?(Rails)
require "beacon_control/backend_request_extension/version"

module BeaconControl
  module BackendRequestExtension
    include BeaconControl::Base::Extension

    self.registered_name = "BackendRequest"

    register_extension! "beacon_control-backend_request_extension"

    def self.load_files
      []
    end
  end
end