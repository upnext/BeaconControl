###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

#
# Abstracts +ActiveRecord+ Beacon or Zone classes instance into one generic BeaconOrZone object instance.
#
class BeaconOrZone
  include Rails.application.routes.url_helpers
  include ActiveModel::Model

  SORTABLE_COLUMNS = %w(range name active)

  attr_accessor :id, :name, :range, :active

  def active?
    active == 1
  end

  def url(application)
    if range == "Zone"
      application_applications_zones_path(application, zone_id: id)
    else
      application_applications_beacons_path(application, beacon_id: id)
    end
  end
end
