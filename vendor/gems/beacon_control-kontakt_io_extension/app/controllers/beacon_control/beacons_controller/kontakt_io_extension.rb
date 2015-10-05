module BeaconControl
  module BeaconsController
    module KontaktIoExtension
      extend ActiveSupport::Concern

      included do
        unless method_defined?(:kontakt_io_extended)
          attr_reader :kontakt_io_extended

          alias_method :_non_kontakt_io_redirect_to_beacons, :redirect_to_beacons

          def redirect_to_beacons
            if kontakt_io_extension_active? && params[:action].to_s == 'create'
              kontakt_io_redirect_to_beacons
            else
              _non_kontakt_io_redirect_to_beacons
            end
          end
        end

        def kontakt_io_extension_active?
          current_admin.account.account_extensions.merge(AccountExtension.where(extension_name: 'Kontakt.io')).exists?
        end

        def kontakt_io_redirect_to_beacons
          case @beacon.vendor
          when 'Kontakt'
            redirect_to beacon_control_kontakt_io_extension.beacons_path
          else
            redirect_to beacons_url
          end
        end
      end
    end
  end
end
