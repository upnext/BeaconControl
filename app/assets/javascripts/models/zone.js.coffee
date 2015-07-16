###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class @Zone
  constructor: (@dom, @managerDom, @moveBeaconsDom, @beaconsDom, @modalDom) ->
    return unless @dom.length > 0

    @initColorPicker()
    if @modalDom.length > 0
      @observeFormSubmit()
      @observeModalAnswer()

  observeFormSubmit: ->
    @dom.submit (e) =>
      if @hasMismatchBeacons() and not @moveBeaconsDom.val()
        e.preventDefault()
        @modalDom.modal('show')

  observeModalAnswer: ->
    @modalDom.find('.modal-button.yes').click (e) => @updateModalAnswer(true)
    @modalDom.find('.modal-button.no').click (e) => @updateModalAnswer(false)

  updateModalAnswer: (answer) ->
    @moveBeaconsDom.val(answer)
    @dom.submit()

  hasMismatchBeacons: ->
    @beaconsDom.filter(':checked').not("[data-group='#{@managerDom.val()}']").length

  initColorPicker: ->
    zoneColorInput = @dom.find('#zone_color')
    zoneNameInput = @dom.find('#zone_name')
    colorButton = @dom.find('.color-button')
    initColor = '#' + zoneColorInput.val()

    @updateLeftPreview(zoneNameInput, initColor)
    colorButton.css(border: 0)

    zoneColorInput.spectrum({
      showPaletteOnly: true,
      showPalette: true,
      clickoutFiresChange: true
      color: initColor,
      preferredFormat: "hex",
      change: (color) =>
        colorButton.css('background-color', color.toHexString())
        @updateLeftPreview(zoneNameInput, color.toHexString())
        zoneColorInput.val(color.toHex())
        zoneColorInput.spectrum('hide')
      show: (color) =>
        position = colorButton.offset()
        position.top += colorButton.outerHeight()
        container.css(position)
    })
    container = zoneColorInput.spectrum('container')
    @dom.on 'click', '.color-button', (event)=>
      event.stopPropagation()
      if container.is(':visible')
        zoneColorInput.spectrum('hide')
      else
        zoneColorInput.spectrum('show')
    colorButton.css('background-color', initColor)

  updateLeftPreview: (zoneNameInput, color)->
    zoneNameInput.css('border-left-color', color)
