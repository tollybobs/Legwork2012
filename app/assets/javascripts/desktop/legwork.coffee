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
    $('#reveal').delay(111).animate
      'margin-left':'100%'
    , 666, 'easeInOutExpo', =>
      $('#reveal').remove()

      @build()

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

    @observeSomeSweetEvents()

  ###
  *------------------------------------------*
  | observeSomeSweetEvents:void (-)
  |
  | Observe events scoped to this class.
  *----------------------------------------###
  observeSomeSweetEvents: ->
    # Window
    Legwork.$wn
      .on 'resize', @onResize

    # Ajaxy
    @$ajaxy
      .on 'click', @onAjaxyLinkClick

  ###
  *------------------------------------------*
  | onResize:void (=)
  | 
  | e:object - event object
  | 
  | Window is being resized.
  *----------------------------------------###
  onResize: (e) =>
    # Reset the mobile header if it exists, otherwise build
    # the mobile menu if the button becomese visible
    if @mobile_menu?
      @mobile_menu.resetHeader()
    else if @$menu_btn.is(':visible') is true
      @mobile_menu = new Legwork.MobileMenu()

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