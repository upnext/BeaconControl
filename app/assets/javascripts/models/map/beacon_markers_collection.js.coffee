###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class BeaconMarkersCollection
  constructor: ->
    @beacons = {}
    @currentBeacon = null

  addBeacon: (beacon) ->
    $(beacon).on('changed', => @setCurrentBeacon(beacon))
    $(beacon).on('deleted', => @removeBeacon(beacon.id))
    @beacons[beacon.id] = beacon

  clear: () ->
    @beacons = {}

  setCurrentBeacon: (beacon) ->
    @currentBeacon = @beacons[beacon.id]
    $(@).trigger('currentBeaconChanged', @currentBeacon)

  unsetCurrentBeacon: ->
    $(@currentBeacon).unbind()
    @currentBeacon = null

    $(@).trigger('currentBeaconUnset')

  removeBeacon: (id) ->
    if beacon = @beacons[id]
      @unsetCurrentBeacon() if beacon == @currentBeacon
      delete @beacons[id]

  allBeacons: ->
    @beacons

  currentIds: ->
    Object.keys(@beacons)

$ ->
  window.BeaconMarkersCollection = BeaconMarkersCollection
