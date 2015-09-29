#= require ext/gmaps/exports
#= require ext/gmaps/gmaps

###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class @Map

  defaultMapOptions =
    lat: 52.31
    lng: 13.24
    zoom: 18
    scrollwheel: true
    streetViewControl: false
    panControl: false
    mapTypeControl: false
    mapTypeId: google.maps.MapTypeId.ROADMAP

  defaultMarkerOptions =
    animation: google.maps.Animation.DROP
    draggable: false

  defaultBehaviourOpts =
    extendBoundsOnMarkerAdd: true


  constructor: (@mapContainer, options, behaviourOpts) ->
    return if @mapContainer == null

    # Array for map markers
    @_markers = {}

    @behaviourOpts = exports.merge(defaultBehaviourOpts, (behaviourOpts || {}))

    # No options provided - assume defaults
    if( options == undefined )
      options = defaultMapOptions
    else
      options = exports.merge(defaultMapOptions, options)

    # Add container to the options
    options = exports.merge( options, { div: @mapContainer } )

    # Create the map
    @map = new GMaps options

    @_bounds = new google.maps.LatLngBounds()

  # ADD/UPDATE METHODS
  # ==================

  # Adds marker to the map
  addMarker: (markerId, lat, lng, options) ->
    return if markerId == undefined
    return if @_markers[markerId] != undefined

    # Make sure the options are there
    # default drop animation, make pin draggable
    options = exports.merge( defaultMarkerOptions, (options || {}) )

    # Merge options with pin location
    markerSettings  = exports.merge( options, {
      lat: (lat || defaultMapOptions.lat),
      lng: (lng || defaultMapOptions.lng)
    })

    # Create the marker and add it to map
    marker = @map.addMarker(markerSettings)

    # Add marker to collection
    @_markers[markerId] = marker

    @extendBounds(marker) if @behaviourOpts.extendBoundsOnMarkerAdd || options.extendBoundsOnMarkerAdd

    # - Drag callbacks
    if( markerSettings.draggable == true && markerSettings.dragCallback != undefined && markerSettings.dragCallbackError != undefined )

      dragFun = @getAddressByCoordinates
      dragCallback = (marker) ->
        latlng = marker.latLng

        dragFun(
          latlng.lat(), latlng.lng(),
          options.dragCallback,
          options.dragCallbackError
        )

      google.maps.event.addListener(
        marker, 'dragend', dragCallback
      )

    marker
    # - Add any other callbacks here if they become needed


  # Add marker to map when we have only address string
  # No support for other inputs - the data should be formatted beforehand

  # - Add support for markerId
  # - Add support for passing callbacks/options
  addMarkerWithAddress: (markerId, address, callback, options) ->
    success = (latlng) =>
      @addMarker(markerId, latlng.lat(), latlng.lng(), options)
      callback(latlng.lat(), latlng.lng())
    fail = () ->
      #alert 'Failed to geocode'

    @geocode(address, success, fail)

  # Update marker info
  updateMarker: (markerId, lat, lng, options) ->
    latlng = new google.maps.LatLng(lat, lng)

    marker = @getMarkerById(markerId)
    marker.setPosition(latlng)
    marker.infoWindow.setContent(options.infoWindow.content)
    @_bounds = new google.maps.LatLngBounds()

    for k, marker of @_markers
      @extendBounds(marker)


  updateMarkerWithAddress: (markerId, address, options) ->
    success = (latlng) =>
      @updateMarker(markerId, latlng.lat(), latlng.lng(), options)
    fail = (results) ->
      #alert 'Failed to geocode'

    @geocode(address, success, fail)


  # REMOVING METHODS
  # ================

  # Remove single marker by markerId
  removeMarker: (markerId) ->
    @_markers[markerId].setMap(null)
    delete @_markers[markerId]

  # Remove all markers from the map
  clearMarkers: ->
    @map.removeMarkers()
    @_markers = {}

  # GET METHODS
  # ================

  # Returns current number of markers
  getMarkersCount: ->
    count = 0

    for i of @_markers
      if( @_markers.hasOwnProperty(i) )
        count++

    count

  # Returns current marker list
  getMarkers: ->
    @_markers

  # Returns marker by ID
  getMarkerById: (markerId) ->
    @_markers[markerId]

  extendBounds: (marker) ->
    if ( @getMarkersCount() == 1)
      @map.setCenter( marker.getPosition().lat(), marker.getPosition().lng() )

    else
      # Extend the bounds of map
      @_bounds.extend( new google.maps.LatLng( marker.getPosition().lat(), marker.getPosition().lng() ) )

      @fitBounds()

  fitBounds: ->
    @map.fitBounds( @_bounds )

  addToBounds: (marker) ->
    @_bounds.extend( new google.maps.LatLng( marker.getPosition().lat(), marker.getPosition().lng() ) )


  geocode: (address, successCallback, errorCallback) ->
    GMaps.geocode({
      address: address,
      callback: (results, status) ->
        if status == 'OK'
          latlng = results[0].geometry.location
          successCallback(latlng)
        else
          if errorCallback != undefined
            errorCallback()
    })

  setCenter: (lat, lng) ->
    @map.setCenter(lat, lng)

  # Returns address by lat/lng
  getAddressByCoordinates: (lat, lng, successCallback, errorCallback) ->
    new Promise((resolve, reject)=>
      latlng      = new google.maps.LatLng(lat, lng)
      geocoderApi = new google.maps.Geocoder()
      geocoderApi.geocode(
        {'latLng': latlng},
        (results, status) ->
          if status is 'OK'
            resolve({results: results, latitude: lat, longitude: lng})
            if typeof successCallback is 'function'
              successCallback(results, lat, lng)
          else
            reject(new Error('Couldn\'t fetch coordinates'))
            if typeof errorCallback is 'function'
              errorCallback()
            else
              alert "Couldn't fetch coordinates"
      )
    )

  getCurrentPosition: (lat, lng)->
    lat = parseFloat(if lat? then lat else '')
    lng = parseFloat(if lng? then lng else '')
    new Promise((resolve, reject)=>
      if not isNaN(lat) and not isNaN(lng)
        resolve({ coords: { latitude: lat, longitude: lng } })
      else if navigator.geolocation
        navigator.geolocation.getCurrentPosition(resolve, reject, enableHighAccuracy: true)
      else
        reject(new Error('Browser does not support geolocation'))
    )

  addMarkerToCurrentPosition: (markerId, lat, lng, options) ->
    @getCurrentPosition(lat, lng).then((pos)=>
      @addMarker(markerId, pos.coords.latitude, pos.coords.longitude, options)
    ).catch((positionError)=>
      @addMarker(markerId, lat, lng, options)
    )
