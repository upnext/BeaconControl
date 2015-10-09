class Beacon
  module KontaktIoExtension
    module ConfigObject
      extend ActiveSupport::Concern

      included do
        unless method_defined?(:kontakt_extended)
          attr_reader :kontakt_extended
          alias_method :_non_kontakt_io_extension_compatibility, :extension_compatibility
          alias_method :_non_kontakt_io_transmission_power, :transmission_power
          alias_method :_non_kontakt_io_signal_interval, :signal_interval

          # Overrides Beacon::ConfigObject#extension_compatibility
          # Prepare data loaded from KontaktIo API.
          def extension_compatibility(hash)
            hash = _non_kontakt_io_extension_compatibility(hash)
            hash[:transmission_power] = hash[:tx_power] if hash.key?(:tx_power)
            hash[:signal_interval] = hash[:interval] if hash.key?(:interval)
            hash.delete(:was_imported)
            hash
          end

          def current_transmission_power
            _non_kontakt_io_transmission_power.to_i
          end

          def current_signal_interval
            _non_kontakt_io_signal_interval.to_i
          end

          def transmission_power
            config.tx_power.to_i rescue _non_kontakt_io_transmission_power
          end

          def signal_interval
            config.interval.to_i rescue _non_kontakt_io_signal_interval
          end
        end
      end
    end
  end
end
