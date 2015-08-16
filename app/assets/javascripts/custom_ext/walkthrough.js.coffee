###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class Walkthrough

  constructor: (@modal, @autorun, @trigger, @steps, @highlights) ->
    return unless @modal.length > 0

    @steps = @steps
      .map (i, item) ->
        $(item).data()
      .sort (i, j) ->
        i.walkthroughIndex - j.walkthroughIndex

    @title = @modal.find(".modal-title")
    @body = @modal.find(".modal-body")
    @prev = @modal.find(".prev")
    @next = @modal.find(".next")
    @start = @modal.find(".start")
    @finish = @modal.find(".finish")
    @step = @modal.find(".step-no")
    @counter = @modal.find(".step-counter")

    $(".step-total", @modal).text(@steps.length-1)

    @observeOpen()
    @observeClose()
    @observeBtn()

  observeOpen: ->
    _self = @
    @open() if @autorun.length > 0
    @trigger.click (e) ->
      e.preventDefault()
      _self.open()

    @modal.on "show.bs.modal", ->
      window.scrollTo(0, 0)

  observeClose: ->
    _self = @
    @modal.on "hide.bs.modal", ->
      _self.highlights.removeClass("walkthrough-highlight")

  observeBtn: ->
    $(".start, .next", @modal).click =>
      @showStep(@currentStep+1)
    $(".prev", @modal).click =>
      @showStep(@currentStep-1)

  open: ->
    @showStep(0)
    @modal.modal('show')

  showStep: (step) ->
    @currentStep = step

    $(".btn", @modal).hide()
    if step == 0
      @start.show()
    else if step == 1
      @next.show()
    else if step > 1 && step < @steps.length-1
      @prev.show()
      @next.show()
    else if step == @steps.length-1
      @prev.show()
      @finish.show()

    @step.text(step)
    if step == 0
      @counter.hide()
    else
      @counter.show()

    @title.text(@steps[step].walkthroughTitle)
    @body.html(@steps[step].walkthroughBody)

    @highlightControls(@steps[step].walkthroughHighlight)

  highlightControls: (index) ->
    @highlights.removeClass("walkthrough-highlight")
    @highlights.filter("[data-walkthrough-highlight=#{index}]").addClass("walkthrough-highlight")


$ ->
  new Walkthrough(
    $("#walkthrough-modal"),
    $(".walkthrough-autorun"),
    $(".walkthrough-trigger"),
    $("[data-walkthrough-index]"),
    $("[data-walkthrough-highlight]")
  )
