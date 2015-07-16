/**
 * Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 * All rights reserved.
 *
 * This source code is licensed under the BSD 3-Clause License found in the
 * LICENSE.txt file in the root directory of this source tree. 
 */

$.fn.elementsSelect = function() {
  return this.each(function() {
    var rootElement = this;
    var elements_select = {
      select_options: [],

      init: function() {
        $(".remove-element", rootElement).click(function () {
          elements_select.remove_element($(this).attr("value"));
          return false
        });

        $(rootElement).on('click', '.add-element', function () {
          var val = $("select", rootElement).val();
          var option = $("option[value='"+val+"']", rootElement);
          elements_select.add_element(option);
          return false
        });

        $("input:checked", rootElement).each(function() {
          var value = $(this).val();
          var option = $("option", rootElement).filter( function() {
            return this.value == value
          });

          elements_select.add_element(option)
        });
      },

      add_element: function(option) {
        value = option.val();
        var checkbox = $(":checkbox", rootElement).filter( function() {
          return this.value == value
        });

        checkbox.prop("checked", true);
        elements_select.select_options[value] = option;
        option.remove();

        $(".element-" + value, rootElement).show();
        $(".element-" + value).attr("val", value);
        $('select.selectpicker', rootElement).selectpicker('refresh');

        $('span.beacons-count').text($('.beacons-table tr:visible').length)
      },

      remove_element: function (value) {
        var checkbox = $(":checkbox", rootElement).filter(function() {
          return this.value == value
        });

        if (checkbox.length) {
          checkbox.prop("checked", false);
          $("select", rootElement).append(elements_select.select_options[value]);

          $(".element-" + value, rootElement).hide();
          $('select.selectpicker', rootElement).selectpicker('refresh');

          $('span.beacons-count').text($('.beacons-table tr:visible').length);
          return true;
        } else {
          return false;
        }
      }
    };
    elements_select.init()
  });
};

$(document).ready(function() {
  $(".elements-select").elementsSelect();
});
