###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module ProximitySearchable
  extend ActiveSupport::Concern

  module ClassMethods
    def find_by_proximity_id(proximity_id)
      proximity = (proximity_id || '').split('+')
      return if proximity[0].blank? || proximity[1].blank? || proximity[2].blank?

      Beacon.joins('LEFT JOIN beacon_proximity_fields AS minorf ON minorf.beacon_id = beacons.id AND minorf.name = \'minor\'').
        joins('LEFT JOIN beacon_proximity_fields AS majorf ON majorf.beacon_id = beacons.id AND majorf.name = \'major\'').
        joins('LEFT JOIN beacon_proximity_fields AS uuidf ON uuidf.beacon_id = beacons.id AND uuidf.name = \'uuid\'').
        where('uuidf.value = ?',  proximity[0]).
        where('majorf.value = ?', proximity[1]).
        where('minorf.value = ?', proximity[2]).first
    end
  end
end
