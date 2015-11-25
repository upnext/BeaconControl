module BeaconControl
  module NeighboursExtension
    class CreateNeighbourService < BaseNeighbourService
      def create(message)
        call message
        first_or_create
      end

      def first_or_create
        any.first_or_create(source_id: current_zone.id, target_id: zone_id)
      end
    end
  end
end
