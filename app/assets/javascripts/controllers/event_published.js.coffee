class @EventPublisher
  constructor: (el)->
    @el = el
    @id = "##{el.attr('id')}"
    el.on('change', ()=>
      @publish()
    ).data('publisher', @)

  readValue: ->
    if @el.is(':checkbox')
      @el.is(':checked')
    else
      @el.val()

  publish: ->
    $(document).trigger('publish', @)

# <div class="event-subscriber" data-published="#beacon_protocol" data-action="show" data-on="change" data-match="iBeacon">
class @EventSubscriber
  constructor: (el)->
    @el = el
    @publisher = el.data('publisher')
    @action = el.data('action')
    @event = el.data('on')
    @value = el.data('match')
    el.data('subscriber', @)
    @listen()
  listen: ->
    $(document).on('publish', (event, publisher)=>
      if publisher.id is @publisher
        match = publisher.readValue() is @value
        @exec @action, match
    )
  exec: (action, match)->
    switch @resolveAction(action, match)
      when 'show'
        @el.show(0)
      when 'hide'
        @el.hide(0)

  resolveAction: (action, match)->
    switch action
      when 'show'
        if match then 'show' else 'hide'
      when 'hide'
        if match then 'hide' else 'show'

$(->
  publishers = []
  $('.event-publisher').each(->
    publishers.push new EventPublisher($(this))
  )
  $('.event-subscriber').each(->
    new EventSubscriber($(this))
  )
  $.each(publishers, -> this.publish())
)