###
 Copyright (c) 2015, Upnext Technologies Sp. z o.o.
 All rights reserved.

 This source code is licensed under the BSD 3-Clause License found in the
 LICENSE.txt file in the root directory of this source tree. 
###

class @SortableTable
  constructor: (dom)->
    @dom = dom
    return if dom.data('sortable-table')
    dom.data('sortable-table', @)
    @observeRows()
    @observeSelectAllCheckboxChange()
    @observeCheckboxChange()
    @observeBatchDeleteClicked()
    @observeSearchField()

  observeRows: ->
    @dom.find('tbody tr td:not(.disable-select)').click (event) =>
      el = $(event.target)
      wrapper = el.closest('.beacons-table')

      if wrapper.hasClass('selectable-rows')
        el.parent().find('input:checkbox').trigger('click')

      else if wrapper.hasClass('linked-rows')
        locationTarget = el.parent().find('.btn-action-edit').attr('href')
        window.location.href = locationTarget if (locationTarget or '').length

  observeSelectAllCheckboxChange: ->
    @dom.find('#select_all').click (event)=>
      if event.target.checked
        $(':checkbox').each (n, el)->
          el.checked = true
          $(el).change()
      else
        $(':checkbox').each (n, el)->
          el.checked = false
          $(el).change()

  observeCheckboxChange: ->
    @dom.on 'change', ':checkbox', (event)=>
      checked_checkboxes = @dom.find("input.value-checkbox:checked")
      tr = null
      btn = null
      el = event.target

      if checked_checkboxes.length == 1
        tr = checked_checkboxes.closest('tr')
        zone_id = tr.data('zone-id')
        floor = tr.data('floor')
        @dom.find('.zone-select > select').selectpicker('val', zone_id)
        @dom.find('.floor-select > select').selectpicker('val', floor)
      else
        @dom.find('.zone-select > select, .floor-select > select').selectpicker('val', null)

      tr = $(event.target).closest('tr')

      if el.checked
        tr.addClass('active')
        btn = tr.find('a.btn-default')

        @dom.find('.floor-select, .zone-select, .batch-delete').removeClass('hidden')
        @dom.find('.selectpicker').selectpicker('refresh')
      else
        tr.removeClass('active')
        btn = tr.find('a.btn-success')

        if checked_checkboxes.length == 0
          @dom.find('.floor-select, .zone-select, .batch-delete').addClass('hidden')
          @dom.find('#select_all').prop('checked', false)

  observeBatchDeleteClicked: ->
    dom = @dom
    batchDelete = @dom.find('.batch-delete')
    batchDelete = batchDelete.find('a') unless batchDelete.is('a')
    url = batchDelete.data('url')
    batchDelete.on 'click', (event)->
      link = $(@)
      link = link.find('a') unless link.is('a')
      target = "#{url}?#{dom.find('input.value-checkbox').serialize()}"
      link.data('url', target)

  observeSearchField: ->
    @dom.on 'keyup', '.sortable_table_search_field', (event) =>
      $(event.target).closest('form').submit() if event.keyCode == 13
