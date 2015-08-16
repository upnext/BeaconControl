class StickyElement
  constructor: (@element, @anchor) ->
    return if (@element.length < 1 || @anchor.length < 1)

    @observeScroll()

  observeScroll: ->
    $(window).scroll(=>
      windowTop = $(window).scrollTop()
      anchorTop = @anchor.offset().top
      if (windowTop > anchorTop)
        @element.addClass('stick')
      else
        @element.removeClass('stick')
    )

$ ->
  new StickyElement(
    $('#sticky'),
    $('#sticky-anchor')
  )
