###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class BeaconsSearchController < AdminController
  before_filter :authenticate_admin!

  has_scope :with_beacon_or_zone_name,    as: :name
  has_scope :with_zone_id, as: :zone_id, type: :array
  has_scope :with_floor,   as: :floor

  def index
    beacons = apply_scopes(collection).all

    render json: beacons, each_serializer: S2sApi::V1::BeaconSerializer, root: 'beacons'
  end

  private

  def collection
    current_admin.account.beacons.includes(:zone).references(:zone).with_location
  end
end
