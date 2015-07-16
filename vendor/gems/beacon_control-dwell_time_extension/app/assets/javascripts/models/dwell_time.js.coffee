###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class DwellTime
  constructor: (@sliderDom, @input) ->
    @initSlider()
    @initInput()

  initSlider: ->
    _self = @
    @sliderMax = @sliderDom.data('slider-max')
    @sliderMin = @sliderDom.data('slider-min')

    @slider = @sliderDom.slider(
      formater: (value) -> return _self.stringWithNumber(value)
    ).on(
      'slide', _self.sliderChanged.bind(_self)
    ).on(
      'slideStop', _self.sliderChanged.bind(_self)
    )

  initInput: ->
    _self = @

    @input.change ->
      currentNumberVal = _self.numberValue($(@).val())

      if currentNumberVal >= _self.sliderMax
        currentNumberVal = _self.sliderMax
      else if currentNumberVal <= _self.sliderMin
        currentNumberVal = _self.sliderMin

      currentStringVal = _self.stringWithNumber(currentNumberVal)

      # Update input on right
      $(@).val(currentStringVal)

      # Update slider
      _self.slider.slider(
        'setValue', currentNumberVal, false
      )
      _self.sliderDom.val(currentNumberVal)

  # When slider is touched
  sliderChanged: ->
    # Update input on right
    @input.val(
      @stringWithNumber(@sliderDom.val())
    )

  stringWithNumber: (val) ->
    "#{val} min"

  numberValue: (str) ->
    parseInt(str) || @sliderMin

$ ->
  window.DwellTime = DwellTime
