require 'proximity_id' unless defined? ProximityId

class ProximityId
  module KontaktIoExtension
    module Extension
      extend ActiveSupport::Concern

      included do
        def kontakt_io_loaded_data
          @kontakt_io_loaded_data ||= load_kontakt_io_data
        end

        def load_kontakt_io_data
          @beacon.beacon_config.load_data(::OpenStruct.new(account: @beacon.try(:account)))
        end

        ::ProximityId::FIELDS.each do |field|
          unless method_defined? :"_non_kontakt_io_#{field}"
            alias_method :"_non_kontakt_io_#{field}", field
            alias_method :"_non_kontakt_io_#{field}=", "#{field}="
          end

          define_method(field) do
            return send(:"_non_kontakt_io_#{field}") unless @beacon
            return send(:"_non_kontakt_io_#{field}") unless @beacon.vendor == 'Kontakt'
            kontakt_io_loaded_data
            if @beacon.respond_to?("current_#{field}")
              return nil unless @beacon.config.present?
              @beacon.send("current_#{field}")
            else
              @beacon.send(field)
            end
          end

          define_method(:"#{field}=") do |value|
            return send(:"_non_kontakt_io_#{field}=", value) unless @beacon
            return send(:"_non_kontakt_io_#{field}=", value) unless @beacon.vendor == 'Kontakt'
            @beacon.send(:"#{field}=", value)
          end
        end
      end
    end
  end
end
