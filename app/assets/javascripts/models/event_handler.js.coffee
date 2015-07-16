###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class @EventHandler
  constructor: ->
    @observers = []

  addEvent: (element, event) ->
    $(element).on(event, (e) =>
      $.each(@observers, (_i, observer) => observer.eventFired(e))
    )

  addOberver: (observer) ->
    @observers.push(observer)
