###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class Walkthrough

  constructor: (@modal, @anotherModal, @autorun) ->
    return unless @modal.length > 0

    @links = @modal.find('a')
    @observeOpen()
    @observeLink()

  observeOpen: ->
    _self = @
    @open() if @autorun.length > 0

    @modal.on "show.bs.modal", ->
      window.scrollTo(0, 0)

  observeLink: ->
    _self = @
    @links.click (e) ->
      _self.openAnotherModal()
      console.log('clicked')

  open: ->
    @modal.modal('show')

  openAnotherModal: ->
    @modal.modal('hide')
    @anotherModal.modal('show')

$ ->
  new Walkthrough(
    $("#walkthrough-modal-first"),
    $("#walkthrough-modal-second"),
    $(".walkthrough-autorun")
  )
