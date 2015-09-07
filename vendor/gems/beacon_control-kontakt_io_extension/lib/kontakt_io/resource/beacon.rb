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
    class Beacon < Base
      attribute :unique_id,  String
      attribute :proximity,  String
      attribute :major,      Integer
      attribute :minor,      Integer
      attribute :name,       String
      attribute :import,     Boolean

      attribute :venue,     String
      #
      # Composes +ProximityId+ string representation of Beacon +uuid,major,minor+ fields.
      #
      def proximity_id
        "#{proximity}+#{major}+#{minor}".upcase
      end

      #
      # Compares +KontaktIo::Resource::Beacon+ with AR Beacon based on:
      #   * +unique_id+ field from Kontakt.io, or
      #   * +proximity,major,minor+ fields compacted to +proximity_id+
      #
      # ==== Parameters
      #
      # +* +db_beacon+ - Beacon from database to compare with
      #
      def ==(db_beacon)
        unique_id == db_beacon.unique_id ||
          proximity_id.to_s == db_beacon.proximity_id.to_s
      end

      def venue=(value)
        super(value.is_a?(KontaktIo::Resource::Venue) ? value : KontaktIo::Resource::Venue.new(value || {}))
      end
    end
  end
end
