###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

$ ->
  zoneForm = new Zone($('.zone-form'), $('#zone_manager_id'), $('#zone_move_beacons'), $('[id^=zone_beacon_ids_]:checkbox'), $('#yes-no-modal'))
