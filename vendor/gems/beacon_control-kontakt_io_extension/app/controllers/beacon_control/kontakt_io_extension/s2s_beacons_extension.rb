module BeaconControl
  module KontaktIoExtension
    module S2sBeaconsExtension
      extend ActiveSupport::Concern

      included do
        unless method_defined?(:kontakt_io_extended)
          attr_reader :kontakt_io_extended
          alias_method :_non_kontakt_io_sync, :sync
        end

        def sync
          if resource.kontakt_io_mapping.present?
            resource.kontakt_io_sync!(current_admin)

            render json: resource,
                   serializer: ::S2sApi::V1::BeaconSerializer
          else
            _non_kontakt_io_sync
          end
        end
      end
    end
  end
end