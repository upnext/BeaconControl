module BeaconControl
  module NeighboursExtension
    class BaseNeighbourService
      ANY = '(source_id = :current_id AND target_id = :zone_id) OR (source_id = :zone_id AND target_id = :current_id)'

      attr_reader :current_zone

      def initialize(current_zone)
        @current_zone = current_zone
      end

      private

      def call(message)
        @message = message
      end

      def zone_id
        @zone_id ||= @message[:neighbour][:zone_id]
      end

      def any
        BeaconControl::NeighboursExtension::ZoneNeighbour.
          where(ANY, current_id: current_zone.id, zone_id: zone_id)
      end
    end
  end
end