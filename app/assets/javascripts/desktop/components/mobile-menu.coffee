###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is hot.

###

class Legwork.MobileMenu

  ###
  *------------------------------------------*
  | constructor:void (-)
  |
  | Construct the fuggin' thing.
  *----------------------------------------###
  constructor: ->
    # Class vars
    @$header = $('header')
    @$nav = $('nav')
    @$menu_btn = $('#menu-btn')
    @initial_time = 0
    @initial_touch = 0
    @last_y = 0
    @direction = 'down'
    @final_touch = 0

    @observeSomeSweetEvents()

  ###
  *------------------------------------------*
  | observeSomeSweetEvents:void (-)
  |
  | Observe events scoped to this class.
  *----------------------------------------###
  observeSomeSweetEvents: ->
    @touch_start = if Modernizr.touch then 'touchstart' else 'mousedown'
    @touch_move = if Modernizr.touch then 'touchmove' else 'mousemove'
    @touch_end = if Modernizr.touch then 'touchend' else 'mouseup'

    @$menu_btn[0].addEventListener(@touch_start, @onTouchStart, false)

  ###
  *------------------------------------------*
  | onTouchStart:void (=)
  |
  | e:object - event object
  |
  | User has initiated a touch.
  *----------------------------------------###
  onTouchStart: (e) =>
    e.preventDefault()

    @initial_time = new Date().getTime()
    @initial_touch = if e.touches? then e.touches[0].pageY - (@$menu_btn.offset().top - Legwork.$wn.scrollTop()) else e.pageY - @$menu_btn.offset().top

    @$header.removeClass('transition')

    Legwork.$wrapper[0].addEventListener(@touch_move, @onTouchMove, false)
    Legwork.$wrapper[0].addEventListener(@touch_end, @onTouchEnd, false)

  ###
  *------------------------------------------*
  | onTouchMove:void (=)
  |
  | e:object - event object
  |
  | User is finger blasting the device.
  *----------------------------------------###
  onTouchMove: (e) =>
    e.preventDefault()

    y = if e.touches? then e.touches[0].pageY else e.pageY
    offset = if y - @initial_touch > 0 then y - @initial_touch else 0

    @direction = if y > @last_y then 'down' else 'up'
    @last_y = y

    if new Date().getTime() - @initial_time < 220
      return false
    else
      @$header.css('margin-top', offset + 'px')

  ###
  *------------------------------------------*
  | onTouchEnd:void (=)
  |
  | e:object - event object
  |
  | User has let 'er go.
  *----------------------------------------###
  onTouchEnd: (e) =>
    Legwork.$wrapper[0].removeEventListener(@touch_move, @onTouchMove, false)
    Legwork.$wrapper[0].removeEventListener(@touch_end, @onTouchEnd, false)

    @final_touch = if e.changedTouches? then e.changedTouches[0].pageY else e.pageY

    if @final_touch - @initial_touch > @$nav.outerHeight()
      @$header.addClass('transition open').css('margin-top', @$nav.outerHeight() + 'px')
    else
      if @initial_touch is @final_touch
        @direction = 'down'
      else if @initial_touch is @final_touch - @$nav.outerHeight()
        @direction = 'up'

      if @direction is 'up'
        @close()
      else if @direction is 'down'
        @open()

  ###
  *------------------------------------------*
  | open:void (=)
  |
  | Open the menu.
  *----------------------------------------###
  open: =>
    @$header.addClass('transition open').css('margin-top', @$nav.outerHeight() + 'px')
    @$nav.one 'click', =>
      setTimeout(@close, 250)

  ###
  *------------------------------------------*
  | close:void (=)
  |
  | Close the menu.
  *----------------------------------------###
  close: =>
    @$header.removeClass('open').addClass('transition').css('margin-top', '0px')

  ###
  *------------------------------------------*
  | resetHeader:void (-)
  |
  | Reset header when app layout changes.
  *----------------------------------------###
  resetHeader: ->
    @$header.removeClass('transition')
    if @$menu_btn.is(':visible') is true and @$header.hasClass('open') is true
      @$header.css('margin-top', @$nav.outerHeight() + 'px')
    else
      @$header.css('margin-top', '0px')
