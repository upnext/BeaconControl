###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class @DeleteCheck
  constructor: (@dom) ->
    @checkboxes = @dom.find("input[type=checkbox].batch-delete-check")
    @buttonBar = @dom.find("div.batch-delete-bar")
    @observeChange()
    @updateButtonBar()

  observeChange: ->
    @checkboxes.on 'change', =>
      @updateButtonBar()

  updateButtonBar: ->
    if @checkboxes.filter(':checked').length > 0
      @buttonBar.show()
    else
      @buttonBar.hide()