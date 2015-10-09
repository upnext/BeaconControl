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
            val = config.tx_power.to_i
            val = current_transmission_power if val == 0
            val
          rescue
            current_transmission_power.to_i
          end

          def signal_interval
            val = config.interval.to_i
            val = current_signal_interval if val == 0
            val
          rescue
            current_signal_interval.to_i
          end
        end
      end
    end
  end
end
