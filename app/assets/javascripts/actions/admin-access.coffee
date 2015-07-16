###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class AdminAccess

  constructor: (selector) ->
    @dom = $(selector)

    if @dom.length
      @handleValidations()

  handleValidations: ->
    @dom.find('form').validate(

        errorPlacement: (error, element) ->
          true

        rules:
          "admin[email]":
            required: true
            email: true

          "admin[password]":
            required: true
    )

$ ->
  new AdminAccess('#admin-access')