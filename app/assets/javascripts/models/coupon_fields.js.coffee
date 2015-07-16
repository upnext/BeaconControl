###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class @CouponFields
  constructor: (@dom) ->
    return unless @dom.length > 0

    @select   = @dom.find('#activity_coupon_attributes_template')
    @mappings = @dom.data('mappings')

    @toggleFields(@select.val())
    @observeCouponTemplateSelect()

  observeCouponTemplateSelect: ->
    @select.change (event)=>
      @toggleFields(event.target.value)

  toggleFields: (templateName) ->
    allowedFields = @mappings[templateName]
    $('.filtered-field').hide()

    @.dom.find('.filtered-field').each (i, el) =>
      if $.inArray($(el).data('name'), allowedFields) != -1
        $(el).show()