class Legwork.Application

  ###
  *------------------------------------------*
  | constructor:void
  |
  | Construct the fuggin' thing.
  *----------------------------------------###
  constructor: ->
    # Class vars
    @$wn = $(window)
    @$doc = $(document)
    @$html = $('html')
    @$body = $('body')
    @$wrapper = $('#wrapper')
    @$header = $('header')
    @$menu_btn = $('#menu-btn')
    @$ajaxy = $('.ajaxy')
    @initial_time = 0
    @initial_touch = 0

    @observeSomeSweetEvents()

  ###
  *------------------------------------------*
  | observeSomeSweetEvents:void (-)
  |
  | Observe events scoped to this class.
  *----------------------------------------###
  observeSomeSweetEvents: ->
    # Conditional events
    ###
    @touch_start = if @$doc[0].ontouchstart? then 'touchstart' else 'mousedown'
    @touch_move = if @$doc[0].ontouchmove? then 'touchmove' else 'mousemove'
    @touch_end = if @$doc[0].ontouchend? then 'touchend' else 'mouseup'
    ###

    @touch_start = 'touchstart'
    @touch_move = 'touchmove'
    @touch_end = 'touchend'

    # Mobile menu
    @$menu_btn[0].addEventListener(@touch_start, @onTouchStart, false)
    @$wrapper[0].addEventListener(@touch_end, @onTouchEnd, false)

    # Ajaxy
    @$ajaxy
      .on 'click', @onAjaxyLinkClick

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
    @initial_touch = if e.touches? then e.touches[0].pageY else e.pageY
    @$wrapper[0].addEventListener(@touch_move, @onTouchMove, false)

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

    @$header.css('margin-top', (y - @initial_touch) + 'px')

  ###
  *------------------------------------------*
  | onTouchEnd:void (=)
  | 
  | e:object - event object
  | 
  | User has let 'er go.
  *----------------------------------------###
  onTouchEnd: (e) =>
    @$wrapper[0].removeEventListener(@touch_move, @onTouchMove, false)

  ###
  *------------------------------------------*
  | onAjaxyLinkClick:void (=)
  | 
  | e:object - event object
  | 
  | User has clicked an ajaxy link.
  *----------------------------------------###
  onAjaxyLinkClick: (e) =>
    $t = $(e.currentTarget)

    if $t.hasClass('selected') is false
      $t.addClass('selected')
    else
      $t.removeClass('selected')

# Kick the tires and light the fires!
$ ->
  window.application = new Legwork.Application