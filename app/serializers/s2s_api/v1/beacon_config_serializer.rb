module S2sApi
  module V1
    class BeaconConfigSerializer < BaseSerializer
      attributes :data,
                 :config_updated_at,
                 :beacon_updated_at,
                 :require_update

      private def data
        object.loaded_data
      end

      private def config_updated_at
        object.updated_at
      end

      private def beacon_updated_at
        object.beacon_updated_at
      end

      private def require_update
        beacon_updated_at.nil? || beacon_updated_at < config_updated_at
      end
    end
  end
end