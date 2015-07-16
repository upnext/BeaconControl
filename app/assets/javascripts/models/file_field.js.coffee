###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class FileField
  constructor: (@fileinput, @remove_file) ->
    @observeClear()
    @observeChange()

  observeClear: ->
    _self = @
    @fileinput.on "clear.bs.fileinput", (e) ->
      _self.remove_file.val(true)

  observeChange: ->
    _self = @
    @fileinput.on "change.bs.fileinput", (e) ->
      _self.remove_file.val(false)

$ ->
  window.FileField = FileField
