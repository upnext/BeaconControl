###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class @BeaconsMap
  constructor: (@viewSelector, @mapSelector) ->
    @viewDom = $(@viewSelector)
    @mapDom  = $(@mapSelector)

    @map = @createMap()

    @currentBeacon = null

    @beaconMarkers = new BeaconMarkersCollection()
    @beaconPreview = new BeaconPreview(@beaconMarkers)
    @beaconActions = new BeaconActions(@beaconMarkers)

  setBeacons: (newBeacons, extendBounds) ->
    existingBeacons = @beaconMarkers.currentIds()

    fetchedBeacons    = $.map(newBeacons, (beacon) -> new BeaconMarker(beacon))
    fetchedBeaconsIds = $.map(fetchedBeacons, (beacon) -> beacon.id)

    # Add new Beacons that are not on map yet
    for beacon in fetchedBeacons
      if $.inArray(beacon.id, existingBeacons) == -1
        @addMarker(beacon)

    # Remove beacons that were not in the fetched collection
    for beaconId in existingBeacons
      if $.inArray(beaconId, fetchedBeaconsIds) == -1
        @removeMarker(beaconId)

    # Adjust map view (used on map load) only if there is at least one beacon
    @extendBounds() if extendBounds && (existingBeacons.length > 0 || fetchedBeacons.length > 0)

  addMarker: (beacon) ->
    marker = beacon.addToMapAsMarker(@map)
    marker.addListener('click', @markerClicked.bind({ module: @, beacon: beacon}))

    @beaconMarkers.addBeacon(beacon)

  extendBounds: ->
    $.each(@beaconMarkers.beacons, (i, beacon) =>
      @map.addToBounds(beacon.marker)
    )

    @map.fitBounds()

  removeMarker: (id) ->
    @map.removeMarker(id)
    @beaconMarkers.removeBeacon(id)

  mapClicked: ->
    @unsetCurrentBeacon()

  # Method invoked in .addMarker(beacon)
  # binds `@module` to this & `@beacon` to clicked beacon
  markerClicked: ->
    @module.setCurrentBeacon(@beacon)

  setCurrentBeacon: (beacon) ->
    @beaconMarkers.setCurrentBeacon(beacon)

  unsetCurrentBeacon: ->
    @beaconMarkers.unsetCurrentBeacon()

  createMap: ->
    googleMap = new Map(
      @mapSelector,
      {
        zoomControlOpt: {
          position: 'RIGHT_BOTTOM'
        },
        panControl: false,
        streetViewControl: false,
        overviewMapControl: false
      }
      {
        extendBoundsOnMarkerAdd: false
      }
    )

    # Yep
    googleMap.map.map.addListener('click', @mapClicked.bind(@))
    googleMap