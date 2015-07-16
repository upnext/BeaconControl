###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

$ ->
  new UuidInput($('.uuid-input'))
  new BootstrapSelect($('.selectpicker'))
  new SelectWithBorder($('.select-with-border'))
  new CookieInfo('#cookie-info')


  $(".pick-a-color").pickAColor
    showSpectrum: false
    showAdvanced: false
    showSavedColors: false
    showBasicColors: false


