require 'beacon_identity_validator' unless defined? BeaconIdentityValidator

class BeaconIdentityValidator
  module KontaktIoExtension
    module Validator
      extend ActiveSupport::Concern

      included do
        unless method_defined? :_non_kontakt_validate_proximity_id!
          alias_method :_non_kontakt_validate_proximity_id!, :validate_proximity_id!

          def validate_proximity_id!(r)
            return _non_kontakt_validate_proximity_id!(r) unless r
            return _non_kontakt_validate_proximity_id!(r) unless r.vendor == 'Kontakt'
            true
          end
        end
      end
    end
  end
end
