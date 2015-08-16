class SidebarHighlighter
  constructor: (@sidebar, @content) ->
    return if (@sidebar.length < 1 || @content.length < 1)

    @elements = @getElements()
    @observeScroll()
    @highlightClosestElement()

  getElements: ->
    @sidebar.find('li a').map((i, el) ->
      link = $(el)
      header = $(link.attr('href'))
      top = header.offset().top
      bottom = top + header.height()
      obj = {
        link: link,
        header: header,
        top: top,
        bottom: bottom
      }
    )

  observeScroll: ->
    $(window).scroll(=> @highlightClosestElement())

  highlightClosestElement: ->
    windowTop = $(window).scrollTop()
    lowest = @elements[0]
    lowestDist = Math.min(Math.abs(windowTop - lowest.top), Math.abs(windowTop - lowest.bottom))

    for el in @elements
      el.link.removeClass('active')
      dist = Math.min(Math.abs(windowTop - el.top), Math.abs(windowTop - el.bottom))
      if (dist < lowestDist)
        lowest = el
        lowestDist = dist

    lowest.link.addClass('active')


$ ->
  new SidebarHighlighter(
    $('.walkthrough-sidebar'),
    $('.content')
  )
