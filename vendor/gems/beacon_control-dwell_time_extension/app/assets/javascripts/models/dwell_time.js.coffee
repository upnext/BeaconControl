###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class @DwellTime
  constructor: (@sliderDom, @input) ->
    @initSlider()
    @initInput()

  initSlider: ->
    @sliderMax = @sliderDom.data('slider-max')
    @sliderMin = @sliderDom.data('slider-min')

    @slider = @sliderDom.slider(
      formater: (value) => @stringWithNumber(value)
    )
    @sliderDom.on(
      'slide', @sliderChanged.bind(@)
    ).on(
      'slideStop', @sliderChanged.bind(@)
    )

  initInput: ->
    @input.on('change', =>
      currentNumberVal = @numberValue(@input.val())

      if currentNumberVal >= @sliderMax
        currentNumberVal = @sliderMax
      else if currentNumberVal <= @sliderMin
        currentNumberVal = @sliderMin

      currentStringVal = @stringWithNumber(currentNumberVal)

      # Update input on right
      @input.val(currentStringVal)

      # Update slider
      @slider.slider(
        'setValue', currentNumberVal, false
      )
      @sliderDom.val(currentNumberVal)
    )

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
