###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class CurrentBeaconHandler
  constructor: (@beaconMarkers) ->
    $(@beaconMarkers).on('currentBeaconChanged', (_e, beacon) => @_currentBeaconChanged(beacon))
    $(@beaconMarkers).on('currentBeaconUnset',   (_e) => @_currentBeaconUnset())

  _currentBeaconChanged: (params) ->
  _currentBeaconUnset:            ->

class BeaconPreview extends CurrentBeaconHandler
  constructor: (@beaconMarkers) ->
    super(@beaconMarkers)

    @_observeDelete()

  _observeDelete: ->
    # Listen for elements that will appear in the future
    $(document).on('click', '#delete-beacon', ->
      $('.delete-modal').modal('show')
    )

    $('.delete-action').on('click', (e) =>
      @beaconMarkers.currentBeacon.deleteBeacon()
      $('.modal').modal('hide')
      false
    )

  _currentBeaconChanged: (beacon) ->
    $('.beacon-info').html(
      HandlebarsTemplates["actions/beacon_info"](beacon.params)
    )

  _currentBeaconUnset: ->
    $('.beacon-info').html('')

class BeaconActions extends CurrentBeaconHandler
  constructor: (@beaconMarkers) ->
    super(@beaconMarkers)

    $('#beacon-actions').hide()
    @_observeZoneChange()
    @_observeFloorChange()

  _currentBeaconChanged: (beacon) ->
    $('#beacon-actions').show()
    zone_select = $('#beacon_set_zone')
    zone_select.val(beacon.zoneId())
    zone_select.selectpicker('refresh')

    @_changeZoneColor(zone_select.find("option:selected"))

    floor_select = $('#beacon_set_floor')
    floor_select.val(beacon.location.floor)
    floor_select.selectpicker('refresh')

  _currentBeaconUnset: ->
    $('#beacon-actions').hide()

  _observeZoneChange: ->
    $('#beacon_set_zone').on('change', (event) =>
      selectedOption = $(event.target).find("option:selected")
      currentBeacon = @beaconMarkers.currentBeacon
      value = selectedOption.val()

      currentBeacon.zoneChanged(value) if currentBeacon?
    )

  _observeFloorChange: ->
    $('#beacon_set_floor').on('change', (event) =>
      selectedOption = $(event.target).find("option:selected")
      currentBeacon = @beaconMarkers.currentBeacon
      value = selectedOption.val()

      currentBeacon.floorChanged(value) if currentBeacon?
    )

  _changeZoneColor: (selectedOption) ->
    color = selectedOption.data('color')
    $('#set-zone div.bootstrap-select').css('border-color', color)



$ ->
  window.BeaconPreview = BeaconPreview
  window.BeaconActions = BeaconActions
