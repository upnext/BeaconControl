###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

$ ->
  beaconForm = new Beacon($('.beacon-form'), '#beacon-map', $('#beacon_location'), $('#beacon_lat'), $('#beacon_lng'))

  if beaconForm.isActive()
    beaconForm.updateMarker()
    beaconForm.updateAddress()

  beaconTable = new BeaconTable($('.beacons-table'))

