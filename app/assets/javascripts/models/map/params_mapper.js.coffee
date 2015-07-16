###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class ParamsMapper
  constructor: (formSelector) ->
    @form        = $(formSelector)
    @params      = {}
    @arrayParams = {}

  map: (key, selector) ->
    @params[key] = selector

  mapArray: (key, selector) ->
    @arrayParams[key] = selector

  fetch: ->
    vals = {}

    $.each(@params, (key, obj) =>
      vals[key] = @form.find(obj).val()
    )

    $.each(@arrayParams, (key, obj) =>
      vals[key] = $.map(@form.find(obj), (el) -> el.value)
    )

    $(@).trigger('paramsChanged', vals)

    return vals

$ ->
  window.ParamsMapper = ParamsMapper
