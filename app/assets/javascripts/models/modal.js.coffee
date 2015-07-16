###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class @Modal
  constructor: (@linkSelector) ->
    @observeLinks()

  observeLinks: ->
    $(document).on('click', @linkSelector, (event)=>
      el = $(event.target)
      el = el.closest('a') unless el.is('a')
      modal         = $(el.data('target'))
      @updateLink(modal, el.data())
      modal.modal('show')
    )

  updateLink: (modal, options) ->
    button = modal.find('.modal-button')
    button.attr('href',   options.url)
