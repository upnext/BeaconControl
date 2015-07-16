###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class @CookieInfo

  constructor: (selector) ->
    @box = $(selector)

    @checkCookies()
    @handleClose()

  checkCookies: ->
    if @readCookie('beaconctrl_cookie_accept') isnt 'Y'
      @box.show()

  readCookie: (name) ->
    nameEQ = name + '='
    ca = document.cookie.split(';')
    i = 0
    while i < ca.length
      c = ca[i]
      while c.charAt(0) is ' '
        c = c.substring(1, c.length)
      if c.indexOf(nameEQ) == 0
        return c.substring(nameEQ.length, c.length)
      i++
    null

  createCookie: (name, value, days) ->
    date = new Date
    date.setTime date.getTime() + days * 24 * 60 * 60 * 1000
    expires = '; expires=' + date.toGMTString()
    document.cookie = name + '=' + value + expires + '; path=/'

  handleClose: ->
    @box.find('#accept-cookies').on 'click', =>
      @createCookie('beaconctrl_cookie_accept', 'Y', 365)
      @box.slideUp 150, =>
        @box.remove()
