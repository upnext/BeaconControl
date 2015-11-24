require 'proximity_id' unless defined? ProximityId

class ProximityId
  module KontaktIoExtension
    module Extension
      extend ActiveSupport::Concern

      included do
        ::ProximityId::FIELDS.each do |field|
          unless method_defined? :"_non_kontakt_io_#{field}"
            alias_method :"_non_kontakt_io_#{field}", field
            alias_method :"_non_kontakt_io_#{field}=", "#{field}="
          end

          define_method(field) do
            return send(:"_non_kontakt_io_#{field}") unless @beacon.present?
            return send(:"_non_kontakt_io_#{field}") unless @beacon.beacon_config.present?
            return send(:"_non_kontakt_io_#{field}") unless @beacon.vendor == 'Kontakt'
            if @beacon.config.has_own_key?(field)
              if @beacon.config.has_old_value?(field)
                @beacon.config.old_value_for(field)
              else
                @beacon.config.send(field)
              end
            else
              send(:"_non_kontakt_io_#{field}")
            end
          end

          define_method(:"#{field}=") do |value|
            send(:"_non_kontakt_io_#{field}=", value)
            @beacon.config["#{field}"] = value if @beacon
            value
          end
        end
      end
    end
  end
end
