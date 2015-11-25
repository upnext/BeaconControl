module BeaconControl
  module NeighboursExtension
    class DestroyNeighbourService < BaseNeighbourService
      def destroy(message)
        call message
        @count = any.count
        any.destroy_all
        @count
      end
    end
  end
end