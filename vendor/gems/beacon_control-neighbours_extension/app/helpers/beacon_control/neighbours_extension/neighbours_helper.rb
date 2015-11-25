module BeaconControl
  module NeighboursExtension
    module NeighboursHelper
      def zones_option_list(zones)
        options_from_collection_for_select zones, 'id', 'name'
      end
    end
  end
end