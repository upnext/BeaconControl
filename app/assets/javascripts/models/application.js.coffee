###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class @Application
  constructor: (@dom) ->
    return unless @dom.length > 0
    @dom.data 'beacon.application', @

    @addApplicationTile = @dom.find('li.add-application')
    @createApplicationTile = @dom.find('li.create-application')
    @applicationNameInput = @createApplicationTile.find('input#application_name')
    @acceptLink = @createApplicationTile.find('a.accept')
    @observeApplicationAddTile()
    @observeApplicationCreateTile()
    @observeCancelApplicationClicked()
    @observeCreateApplicationClicked()
    @observeApplicationNameInput()

  observeApplicationAddTile: ->
    @dom.find('.add-application').click =>
      @addApplicationTile.hide()
      @createApplicationTile.removeClass('hidden')
      @createApplicationTile.find('input').focus()
      @acceptLink.hide()
      @applicationNameInput.focus()

  observeCancelApplicationClicked: ->
    @createApplicationTile.find('a.cancel').click (event) =>
      @cancelApplicationCreate()
      event.preventDefault()

  observeCreateApplicationClicked: ->
    @acceptLink.click (event) =>
      event.preventDefault()
      @createApplication()

  observeApplicationNameInput: ->
    @applicationNameInput.bind 'input', (event)=>
      if event.target.value
        @acceptLink.show()
      else
        @acceptLink.hide()

  observeApplicationCreateTile: ->
    $(document).mouseup (event) =>
      if not @createApplicationTile.is(event.target) && @createApplicationTile.has(event.target).length == 0
        @cancelApplicationCreate()


  cancelApplicationCreate: ->
    @addApplicationTile.show()
    @createApplicationTile.addClass('hidden')
    @applicationNameInput.val("")

  createApplication: ->
    @dom.find('form.application').submit()
