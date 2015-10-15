###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class BeaconMarkerRequest
  constructor: (@method, @path, params) ->
    @params = { beacon: params }

  call: ->
    $.ajax(
      url:      @path
      type:     @method
      dataType: 'json'
      data:     @params
    )


class BeaconMarker
  constructor: (@params) ->
    @initWithParams(@params)
    @marker = null

  initWithParams: (params) ->
    @id       = params.id.toString()
    @zone     = params.zone
    @location = params.location

  addToMapAsMarker: (map) ->
    @marker = map.addMarker(@id, @location.lat, @location.lng, {
      draggable: false
      animation: false
      icon: @icon()
    })
    @marker

  icon: ->
    {
      path: fontawesome.markers.MAP_MARKER
      scale: 0.6
      strokeWeight: 0.2
      strokeColor: '#' + @zoneColor()
      strokeOpacity: 1
      fillColor: '#' + @zoneColor()
      fillOpacity: 0.7
    }

  zoneId: ->
    @zone.id if @zone

  zoneColor: ->
    if @zone
      @zone.color
    else
      '000'

  zoneChanged: (zoneId) ->
    @_request('PUT', { zone_id: zoneId }, @zoneChangeDone.bind(@))
    false # stops Event Propagation

  zoneChangeDone: (params) ->
    @params = params
    @initWithParams(@params)

    $(@).trigger('changed')

    @marker.setIcon(
      @icon()
    )

  floorChanged: (floor) ->
    @_request('PUT', { floor: floor }, @floorChangeDone.bind(@))
    false # stops Event Propagation

  floorChangeDone: (params) ->
    @params = params
    @initWithParams(@params)

    $(@).trigger('changed')

  deleteBeacon: ->
    @_request('DELETE', {}, @deleteDone.bind(@))
    false # stops Event Propagation

  deleteDone: ->
    @marker.setMap(null)

    $(@).trigger('deleted')

  _request: (method, params = {}, callback) ->
    req = new BeaconMarkerRequest(method, "/beacons/#{@id}", params)
    req.call().success((res) => @_beaconUpdated(res.beacon, callback))

  _beaconUpdated: (res, callback = null) ->
    callback(res) if callback


$ ->
  window.BeaconMarker = BeaconMarker
