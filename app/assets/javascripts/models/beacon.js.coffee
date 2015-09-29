###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class @Beacon
  constructor: (@dom, @mapDom, @locationDom, @latDom, @lngDom) ->
    @map = null

    return unless @dom.length > 0

    @createMap()
    @observeLocationField()
    @observeLatLngFields()
    @fillFields() if $('form.beacon-new').length
    @setupWatcher()

  createMap: ->
    @map = new Map(@mapDom,
      zoomControlOpt:
        position: 'RIGHT_BOTTOM'
    )

  isActive: ->
    @map != null

  updateMarker: ->
    @map.clearMarkers()
    @map.addMarkerToCurrentPosition('beacon', @latDom.val(), @lngDom.val(), {
      draggable: true
      dragCallback: @markerDragged.bind(@)
      dragCallbackError: (-> return) # no-op for error
    })

  observeLocationField: ->
    @locationDom.change (event)=>
      @map.clearMarkers()
      @map.addMarkerWithAddress('beacon', @locationDom.val(), @updateLatLng.bind(@), {
        draggable: true
        dragCallback: @markerDragged.bind(@)
        dragCallbackError: (-> return) # no-op for error
      })

  observeLatLngFields: ->
    @latDom.change => @updateMarkerForLatLng()
    @lngDom.change => @updateMarkerForLatLng()

  updateMarkerForLatLng: ->
      @map.clearMarkers()
      @map.addMarker('beacon', @latDom.val(), @lngDom.val(), {
        draggable: true
        dragCallback: @markerDragged.bind(@)
        dragCallbackError: (-> return) # no-op for error
      })
      @updateAddress() unless @locationDom.val() and @locationDom.val().trim().length

  markerDragged: (results, lat, lng) ->
    res = results[0]
    @locationDom.val(res.formatted_address)
    @latDom.val(lat)
    @lngDom.val(lng)

  updateLatLngError: ->
    # no-op

  updateLatLng: (lat, lng) ->
    @latDom.val(lat)
    @lngDom.val(lng)

  updateAddress: ->
    @map.getAddressByCoordinates(
      @latDom.val(),
      @lngDom.val(),
      false,
      ->
    ).then((results)=>
      results = results.results if results.results
      @locationDom.val(results[0].formatted_address)
    ).catch(=> @locationDom.val(''))

  fillFields: ->
    @map.getCurrentPosition().then((position)=>
      @map.getAddressByCoordinates(position.coords.latitude, position.coords.longitude)
    ).then((data)=>
      result = if data and data.results then data.results[0] else null
      if result
        @lngDom.val data.longitude
        @latDom.val data.latitude
        @locationDom.val result.formatted_address
    ).catch((error)=> console.error(error) )

  setupWatcher: ->
