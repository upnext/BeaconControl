module ExtensionData
  class KontaktIo
    def initialize(application)
      self.application = application
      self.range_ids = []
    end

    def as_json
      application.triggers.includes(:beacons, :zones).each do |trigger|
        range_ids.push *trigger.beacon_ids
      end

      { kontakt_io: {
        ranges: ranges
      } }
    end

    def merge!(hash)
      ranges.each do |beacon|
        hash[:ranges].each do |json|
          json.deeper_merge!(beacon) if json[:id] == beacon[:id]
        end
      end
      hash
    end

    private

    def zone_range_ids
      Beacon.where(zone_id: application.zone_ids)
    end

    def ranges
      serialized_collection(
        Beacon.joins(:kontakt_io_mapping).where(id: (zone_range_ids | range_ids).compact)
      )
    end

    def serialized_collection(collection)
      collection.map do |beacon|
        {
          unique_id: beacon.kontakt_uid,
          id: beacon.id
        }
      end
    end

    attr_accessor :application, :range_ids
  end
end