module BeaconControl
  module NeighboursExtension
    class LoadNeighbourService < BaseNeighbourService
      def all
        BeaconControl::NeighboursExtension::ZoneNeighbour.for_zones(current_zone)
      end

      def all_neighbour_zone
        all.map do |neighbour|
          neighbour.target == current_zone ? neighbour.source : neighbour.target
        end.compact
      end

      def json_for_all
        all_neighbour_zone.map do |zone|
          {
            id: zone.id,
            label: zone.name,
            color: zone.hex_color
          }
        end
      end
    end
  end
end
