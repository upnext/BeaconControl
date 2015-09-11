class @FormChangeWatcher
  constructor: (el)->
    @el = el
    @el.data('form-watcher', @)
    @inputs = []
    @cache = {}
    @pageLocked = false
    @lockable = @el.is('.form-lockable')
    el.find('input, textarea, select').each((n, el)=>
      @register($(el))
    )
    @setEvents()
  register: (el)->
    return unless el.attr('name') and el.attr('name').length
    @inputs.push(el)
    @cache[ @buildKey(el) ] = @readValue(el)
  buildKey: (el)->
    cls = (el.attr('class') || '').replace(/\s+/ig, '.')
    "#{el[0].tagName}##{el.attr('id')}.#{cls}[name=#{el.attr('name')}]"
  readValue: (el)->
    if el.is(':checkbox')
      el.is(':checked')
    else
      el.val()
  setEvents: ->
    @el.on('change', (event)=>
      @checkFieldUnsave($(event.target))
      @pageLocked = @checkUnsaved().length > 0
    )
  checkFieldUnsave: (el, emit=true)->
    key = @buildKey(el)
    return false if @cache[key] is undefined
    old = @cache[key]
    current = @readValue(el)
    if emit
      if old isnt current
        @emitChanged(el, old, current)
      else
        @emitGood(el, current)
      @el.trigger('form:change', @)
    old isnt current
  emitChanged: (el, old, current)->
    @el.trigger('form:field:changed', [el, old, current])
  emitGood: (el, current)->
    @el.trigger('form:field:ok', [el, current])
  checkUnsaved: (emit=true)->
    unsaved = []
    for el in @inputs
      if @checkFieldUnsave(el, emit)
        unsaved.push(el)
    unsaved
  isUnsaved: ->
    @checkUnsaved(false).length > 0
  isLocked: ->
    return false unless @lockable
    @pageLocked
  @WATCHES = []
  @isLocked: ->
    for form in @WATCHES
      if form.isLocked()
        return true
    false

$(->
  $('form.watchable').each(->
    form = $(this)
    FormChangeWatcher.WATCHES.push(new FormChangeWatcher(form))
  )
  window.onbeforeunload = ->
    if FormChangeWatcher.isLocked()
      'Some fields has changed, are you sure you want abandon those changes?'
)