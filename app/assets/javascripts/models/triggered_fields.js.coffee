###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class TriggeredFields
  constructor: (@form, @observedField, @fieldsSelector) ->
    @observeField()
    @initFields()

  initFields: ->
    @fields = @form.find(@fieldsSelector)

    # First use
    @showForSelected()

  observeField: ->
    _self = @
    @observedField.change ->
      _self.showForSelected()


  showForSelected: ->
    @hideAndDisableAllFields()

    # Get name of selected input radio
    name = @observedField.filter(':checked').val()

    # Enable fields with specific class
    if name
      @showAndEnableFields(
        @fields.filter(".field-triggered-#{name}")
      )

  hideAndDisableAllFields: ->
    @fields.hide()
    @fields.find('input').attr('disabled', true)


  showAndEnableFields: (fields) ->
    fields.show()
    fields.find('input').attr('disabled', false)


$ ->
  window.TriggeredFields = TriggeredFields

