#class @SliderSelectCell
#  constructor: (el)->
#    @el = el
#    @button = @el.find('button')
#    @el.data('slider-select-cell', @)
#
#  readValue: ->
#    @button.prop('value')
#
#class @SliderSelect
#  constructor: (el)->
#    @el = el
#    @cells = []
#    @el.data('slider-select', @)
#    @fixValue()
#    @mount()
#
#  mount: ->
#    wrapper = @createWrapper()
#    wrapper.insertAfter(@el)
#    @el.hide(0)
#    @changeValue(null, @findCell(@el.val()))
#
#  findCell: (value)->
#    for cell in @cells
#      if cell.readValue() is value
#        return cell
#
#  fixValue: ->
#    if parseInt(@el.val()) in [1..7] is false
#      @el.val(1)
#
#
#  createWrapper: ->
#    @wrapper = $("<div class='slider-select-wrapper'></div>")
#    for i in [1..7]
#      @wrapper.append(@createCell(i))
#    @wrapper
#
#  # @param {Number} val
#  createCell: (val)->
#    cell = $("<span class='slider-select-cell'><button class='slider-select-button' value='#{val}'></span>")
#    cell = new SliderSelectCell(cell)
#    cell.el.find('button').on('click', (event)=> @changeValue(event, cell) )
#    @cells.push(cell)
#    cell.el
#
#  changeValue: (event, cell)->
#    if event
#      event.preventDefault()
#    value = cell.readValue()
#    @el.val(value)
#    @el.trigger('change')
#    @wrapper.attr('slider-select-value', value)
#
#$(->
#  $('.slider-select').each(->
#    new SliderSelect($(this))
#  )
#)
