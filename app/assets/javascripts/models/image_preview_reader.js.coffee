###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class ImagePreviewReader
  constructor: (@input) ->

  isPresent: ->
    @input.files and @input.files[0]

  file: ->
    @input.files[0]

  read: (fn) ->
    return "" unless @isPresent()

    reader = new FileReader()
    reader.filename = @filename()
    reader.extension = @extension()

    reader.readAsDataURL(@file())
    reader.onload = fn

  filename: ->
    $(@input).data('name')

  extension: ->
    @file().name.split('.').pop()

$ ->
  window.ImagePreviewReader = ImagePreviewReader
