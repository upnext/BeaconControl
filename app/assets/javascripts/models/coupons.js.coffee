###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class @CouponPreview
  constructor: (@dom) ->

  updateHtml: (data) ->
    @dom.html(data)

class @Coupon
  constructor: (@dom, @previewObject) ->
    @couponDetails = {}
    @observeFields()
    @setInit()
    @inputs = 'input, select, textarea'

  observeFields: ->
    _self = @

    @observeFiles()

    @dom.find('input[type="text"], textarea').keyup ->
      # TODO: Get rid of activity.coupon_attributes
      _self.updatePreview($(@).serializeJSON().activity.coupon_attributes)

    @dom.find('input[type="text"], select').change ->
      # TODO: Get rid of activity.coupon_attributes
      _self.updatePreview($(@).serializeJSON().activity.coupon_attributes)

  updatePreview: (attrJSON) ->
    @couponDetails = $.extend(@couponDetails, attrJSON)

    @updateFrame()

  updateFrame: ->
    template = "mobile/#{@couponDetails.template}"

    html = HandlebarsTemplates[template](@couponDetails)

    @previewObject.updateHtml(html)

  couponData: ->
    # TODO: Get rid of activity.coupon_attributes
    @dom.find('input, select, textarea').serializeJSON().activity.coupon_attributes

  observeFiles: ->
    _self = @

    @dom.find('input[type="file"]').change ->
      r = new ImagePreviewReader(@, _self.fetchImages)
      r.read(_self.updateImage.bind(_self))

    @dom.find('.fileinput').on "clear.bs.fileinput", (e) =>
      @clearImage(e.target)

  setInit: ->
    @couponDetails = @couponData()
    $.each(@dom.find('input[type="file"]'), (i, el)=>
      @couponDetails["#{$(el).data('name')}_url"] = $(el).data('cache-url')
    )
    @updateFrame()

  updateImage: (res) ->
    @addFile(res.target)

  clearImage: (res) ->
    el = $(res).find('input[type="file"]')
    delete @couponDetails["#{el.data('name')}_url"]
    @updateFrame()

  addFile: (image) ->
    @couponDetails["#{image.filename}_url"] = image.result

    @updateFrame()