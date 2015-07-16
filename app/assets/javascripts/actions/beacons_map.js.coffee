###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

$ ->
  if $('.map-view').length > 0
    $('.map-view input:checkbox').bootstrapSwitch
      animate: false
      inverse: true
      handleWith: 60
      onColor: 'primary'
      size: 'small'

    map = new BeaconsMap('.map-view', '#beacons-map')

    paramsMapper = new ParamsMapper('.map-view')

    paramsMapper.mapArray('zone_id', 'input[name="beacon[zone_id][]"]:checked')
    paramsMapper.map('name',  'input[name="beacon[name]"]')
    paramsMapper.map('floor', 'select[name="beacon[floor]"]')

    $(paramsMapper).on('paramsChanged', (e, values) ->
      window.history.replaceState(null, null, "#{window.location.pathname}?#{$.param(values)}")
    )

    fetcher = new BeaconListFetcher('/beacons_search', paramsMapper, map.setBeacons.bind(map))
    fetcher.fetch(true)

    eventHandler = new EventHandler()
    eventHandler.addEvent('#beacon_floor', 'change')
    eventHandler.addEvent('#beacon_name', 'change keyup')
    eventHandler.addEvent('.map-view-sidebar input:checkbox', 'switchChange.bootstrapSwitch')
    eventHandler.addOberver(fetcher)
