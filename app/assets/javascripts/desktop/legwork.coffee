###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is hot.

###

class Legwork.Application

  ###
  *------------------------------------------*
  | constructor:void (-)
  |
  | Construct the fuggin' thing.
  *----------------------------------------###
  constructor: ->
    # Global vars
    Legwork.$wn = $(window)
    Legwork.$doc = $(document)
    Legwork.$html = $('html')
    Legwork.$body = $('body')
    Legwork.$wrapper = $('#wrapper')
    Legwork.$header = $('header')
    Legwork.$view = $('#legwork')
    Legwork.$footer = $('footer')

    # Class vars
    @$menu_btn = $('#menu-btn')
    @$ajaxy = $('.ajaxy')
    @$stuff_wrap = $('#wrap-the-stuff')
    @$stuff_reveal = $('#reveal-the-stuff')

    @preload()

  ###
  *------------------------------------------*
  | preload:void (-)
  |
  | Merge assets and preload.
  *----------------------------------------###
  preload: ->
    @preloader = new Legwork.MainLoader({'$el':Legwork.$body, 'assets':{images:[], videos:[]}})

    Legwork.$body
      .off('Legwork.loaded', @onLoadComplete)
      .one('Legwork.loaded', @onLoadComplete)

  ###
  *------------------------------------------*
  | onLoadComplete:void (=)
  |
  | e:object - event object
  |
  | Loading complete, finish transition.
  *----------------------------------------###
  onLoadComplete: (e) =>
    @build()

    @$stuff_reveal.delay(111).animate
      'margin-left':'100%'
    , 666, 'easeInOutExpo', =>
      @$stuff_reveal.remove()

      Legwork.$header.find('h1')
        .animate
          'margin-bottom':'0px'
        , 666, 'easeInOutExpo'

  ###
  *------------------------------------------*
  | build:void (-)
  |
  | DOM manipulations, instantiations, etc.
  *----------------------------------------###
  build: ->
    # Build the mobile menu if the button is visible
    if @$menu_btn.is(':visible') is true
      @mobile_menu = new Legwork.MobileMenu()

    # Add the stuff
    for stuff, id in Legwork.home.layout
      # Container
      $container = $(JST['desktop/templates/stuff'](stuff))

      # Content
      $content = $('')

      # Append to DOM
      $container.html($content).appendTo(@$stuff_wrap)

    @$stuff = $('.stuff')

    @observeSomeSweetEvents()

  ###
  *------------------------------------------*
  | layout:void (-)
  |
  | Compute layout for current window width.
  *----------------------------------------###
  layout: ->
    w = @$stuff_wrap.outerWidth()

    @$stuff.each (index, $t) =>
      # NOTE: couldn't get $t.data('position') here. jQuery bug?
      $t = $('.stuff').eq(index)
      $t.css(@getLayoutOffset($t.data('position'), w))

  ###
  *------------------------------------------*
  | getLayoutOffset:object (-)
  |
  | p:array - [top, left]
  | w:number - current container width
  |
  | Get the position for the passed coords.
  *----------------------------------------###
  getLayoutOffset: (p, w) ->
    return {
      'top': Math.floor(w * p[0]) + 'px',
      'left': Math.floor(w * p[1]) + 'px'
    }

  ###
  *------------------------------------------*
  | observeSomeSweetEvents:void (-)
  |
  | Observe events scoped to this class.
  *----------------------------------------###
  observeSomeSweetEvents: ->
    # Window
    Legwork.$wn
      .on('resize', @onResize)
      .trigger('resize')

    # Ajaxy
    @$ajaxy
      .on('click', @onAjaxyLinkClick)

  ###
  *------------------------------------------*
  | onResize:void (=)
  | 
  | e:object - event object
  | 
  | Window is being resized.
  *----------------------------------------###
  onResize: (e) =>
    # Global cache window size
    Legwork.app_width = Legwork.$wn.width()

    # Reset the mobile header if it exists, otherwise build
    # the mobile menu if the button becomese visible
    if @mobile_menu?
      @mobile_menu.resetHeader()
    else if @$menu_btn.is(':visible') is true
      @mobile_menu = new Legwork.MobileMenu()

    @layout()

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

    if $t.hasClass('selected') is true
      $t.removeClass('selected')
      return false

    @$ajaxy.removeClass('selected')
    $t.addClass('selected')

# Kick the tires and light the fires!
$ ->
  window.application = new Legwork.Application