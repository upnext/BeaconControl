###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class @UuidInput
  @MASK = '?********-****-****-****-************'

  constructor: (@dom) ->
    @dom.inputmask(
      mask: UuidInput.MASK,
      greedy: false
      definitions:
        '*': /[\da-f]/i
    )
    @fixWriteBuffer el for el in @dom
  fixWriteBuffer: (el)->
    el = $(el)
    mask = el.data('bs.inputmask')
    return if mask.__writeBuffer__
    mask.__writeBuffer__ = mask.writeBuffer
    mask.writeBuffer = ->
      el.trigger 'beforewrite.bs.inputmask'
      mask.buffer[n] = c.toUpperCase() for c, n in mask.buffer
      mask.__writeBuffer__()
      el.trigger 'afterwrite.bs.inputmask'
