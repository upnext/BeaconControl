###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class @SelectWithBorder
  constructor: (@dom) ->
    @_observeChange()

  _observeChange: ->
    @dom.on('change', ->
      selectedOption = $(@).find("option:selected")
      color = selectedOption.data('color')

      if color == undefined || color == ""
        color = 'transparent'

      $(@).parent().find('div.bootstrap-select').css('border-color', color)
    )