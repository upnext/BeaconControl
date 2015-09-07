###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module KontaktIo
  module Resource

    #
    # Kontakt.io Beacon object
    #
    class Venue < Base
      attribute :image, String # "http://kontakt.io/venue/2fca7d99-07a7-46d7-91c0-70e93526bdfb/image",
      attribute :lng, String # null,
      attribute :access, String # "OWNER",
      attribute :devices_count, Integer # 4,
      attribute :id, String # "2fca7d99-07a7-46d7-91c0-70e93526bdfb",
      attribute :description, String # "Main entrance",
      attribute :manager_id, String # "65a0c6d5-9d3b-422e-a4de-81308ea7b876",
      attribute :name, String # "Entrance 1",
      attribute :priv, Boolean # true,
      attribute :coverType, String # null,
      attribute :lat, String # null,

      #
      # Compares +KontaktIo::Resource::Beacon+ with AR Beacon based on:
      #   * +unique_id+ field from Kontakt.io, or
      #   * +proximity,major,minor+ fields compacted to +proximity_id+
      #
      # ==== Parameters
      #
      # +* +db_beacon+ - Beacon from database to compare with
      #
      def ==(local)
        unique_id == local.unique_id ||
          proximity_id.to_s == local.proximity_id.to_s
      end
    end
  end
end
