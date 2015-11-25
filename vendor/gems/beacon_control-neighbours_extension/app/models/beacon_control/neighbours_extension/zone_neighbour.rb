module BeaconControl
  module NeighboursExtension
    class ZoneNeighbour < ActiveRecord::Base
      belongs_to :source,
                 class_name: 'Zone'

      belongs_to :target,
                 class_name: 'Zone'

      validates :target_id,
                uniqueness: { scope: :source_id }

      scope :for_zones, ->(*zones) {
        where('source_id IN (?) OR target_id IN (?)', zones.map(&:id), zones.map(&:id)).
          uniq('source_id, target_id')
      }
    end
  end
end