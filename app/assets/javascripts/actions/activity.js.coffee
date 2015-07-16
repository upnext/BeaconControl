###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

$ ->
  new TriggeredFields(
    $('.new_activity, .edit_activity'),
    $('.activity-buttons input'),
    '.field-triggered'
  )

  new TriggeredFields(
    $('.new_activity, .edit_activity'),
    $('.range-buttons input'),
    '.range-field-triggered'
  )

  new FileField(
    $('#activity-logo .fileinput'),
    $('#activity_coupon_attributes_logo_attributes_remove_file')
  )
  new FileField(
    $('#activity-image .fileinput'),
    $('#activity_coupon_attributes_image_attributes_remove_file')
  )

  new DeleteCheck(
    $('.activities')
  )

  $('.range-field-triggered .selectpicker').selectpicker()
