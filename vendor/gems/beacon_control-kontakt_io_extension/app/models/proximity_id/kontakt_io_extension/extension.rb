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
            return send(:"_non_kontakt_io_#{field}") unless @beacon
            return send(:"_non_kontakt_io_#{field}") unless @beacon.vendor == 'Kontakt'
            mth = @beacon.respond_to?("current_#{field}") ? "current_#{field}" : field
            @beacon.public_send(mth)
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
