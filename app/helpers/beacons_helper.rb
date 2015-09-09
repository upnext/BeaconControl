module BeaconsHelper

  # @param [Array<Zone>] coll
  # @return [Array]
  def select_zone_collection_from(coll)
    coll.map do |zone|
      [
        truncate(zone.name, length: 40),
        zone.id,
        {
          class: %W[with-border],
          style: %W(border-color: #{zone.hex_color}),
          data: {
            group: zone.manager_id.to_s,
            color: zone.hex_color
          }
        }
      ]
    end
  end
end