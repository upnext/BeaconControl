#= require ./sortable_table
#= require_self

###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class @BeaconTable extends SortableTable
  constructor: (@dom) ->
    super @dom
    @observeFloorSelectChange()
    @observeZoneSelectChange()

  observeFloorSelectChange: ->
    floorSelect = @dom.find('.floor-select select')
    floorSelect.change (event)=>
      @dom.find('#beacon_floor').val( floorSelect.val() )
      @dom.find('#beacon_zone_id').prop('disabled', true)
      @dom.find('.batch-update-form').submit()

  observeZoneSelectChange: ->
    zoneSelect = @dom.find('.zone-select select')
    zoneSelect.change (event)=>
      @dom.find('#beacon_zone_id').val(zoneSelect.val())
      @dom.find('#beacon_floor').prop('disabled', true)
      @dom.find('.batch-update-form').submit()
