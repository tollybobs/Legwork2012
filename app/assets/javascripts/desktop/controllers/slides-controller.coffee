###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is hot.

###

class Legwork.Controllers.SlidesController

  ###
  *------------------------------------------*
  | constructor:void (-)
  |
  | options:object - initialization object
  |
  | Construct the fuggin' thing.
  *----------------------------------------###
  constructor: (options) ->
    # Class vars
    @options = options
    @model = options.model
    @zone = options.zone
    @slug = options.slug
    @slide_views = []
    @protime

  ###
  *------------------------------------------*
  | build:$el (-)
  |
  | Build DOM based on model.
  *----------------------------------------###
  build: ->
    @$el = $(JST["desktop/templates/#{@zone}-detail"]({model: @model, slug: @slug, zone: @zone}))
    $slides = @$el.find('.slides')

    for slide in @model.slides
      slide_view = new slide.type({model: slide})
      $slides.append slide_view.build()
      @slide_views.push(slide_view)

    @$ctrl = @$el.find('.slide-controls')

    if Legwork.pro_tip is true then @showProTip()

    return @$el

  ###
  *------------------------------------------*
  | initialize:void (-)
  |
  | Initialize slides after build
  *----------------------------------------###
  initialize: ->
    for view in @slide_views
      view.initialize()

  ###
  *------------------------------------------*
  | activate:void (-)
  |
  | Shows the element
  *----------------------------------------###
  activate: ->
    @reset()

    setTimeout =>
      @$el.addClass('open')
    , 0

    @$ctrl.on Legwork.touchstart, @nextSlide
    Legwork.$doc.on 'keyup.slider', @handleArrowKeys

  ###
  *------------------------------------------*
  | deactivate:void (-)
  |
  | Hides the element
  *----------------------------------------###
  deactivate: ->
    @$el.removeClass('open')
    @$ctrl.off Legwork.touchstart, @nextSlide
    Legwork.$doc.off 'keyup.slider', @handleArrowKeys

  showProTip: ->
    if Legwork.pro_tip is true
      $('#detail-pro-tip').addClass('instructor')

      Legwork.$doc.one Legwork.touchstart, @removeProTip
      Legwork.$doc.one 'keyup.protip', @removeProTip

      @protime = setTimeout(@removeProTip, 6000)

  removeProTip: ->
    if Legwork.pro_tip is true
      Legwork.pro_tip = false

      clearTimeout(@protime)
      $('#detail-pro-tip').removeClass('instructor')

      setTimeout =>
        $('#detail-pro-tip').remove()
      , 333

  ###
  *------------------------------------------*
  | reset:void (-)
  |
  | Reset the slides so that the
  | title-screen slide is first/current
  *----------------------------------------###
  reset: ->
    $s = @$el.find('.slide')
    $sf = $s.first()
    total_cnt = $s.length
    current_cnt = $sf.index()

    $s.removeClass('current').css('left', '100%')
    $sf.addClass('current').css('left', '0%')

    @$el.find('.current-cnt').text(current_cnt + 1)
    @$el.find('.total-cnt').text(total_cnt)

  ###
  *------------------------------------------*
  | nextSlide:void (=)
  |
  | Next. Next slide.
  *----------------------------------------###
  nextSlide: =>
    @$ctrl.off Legwork.touchstart, @nextSlide
    Legwork.$doc.off 'keyup.slider', @handleArrowKeys

    $slide_current = @$el.find('.slide.current')
    $slide_first = @$el.find('.slide').first()
    $slide_next = if $slide_current.next().length then $slide_current.next() else $slide_first

    $slide_current.removeClass('current').css('left', '0%').stop().animate
      left: '-100%'
    , 666, 'easeInOutExpo'

    $slide_next.addClass('current').css('left', '100%').stop().animate
      left: '0%'
    , 666, 'easeInOutExpo', =>
      @$ctrl.on Legwork.touchstart, @nextSlide
      Legwork.$doc.on 'keyup.slider', @handleArrowKeys

  ###
  *------------------------------------------*
  | priorSlide:void (=)
  |
  | Prior. Prior slide.
  *----------------------------------------###
  priorSlide: =>
    @$ctrl.off Legwork.touchstart, @nextSlide
    Legwork.$doc.off 'keyup.slider', @handleArrowKeys

    $slide_current = @$el.find('.slide.current')
    $sl = @$el.find('.slide').last()
    $slide_prior = if $slide_current.prev().length then $slide_current.prev() else $sl

    $slide_current.removeClass('current').css('left', '0%').stop().animate
      left: '100%'
    , 666, 'easeInOutExpo'

    $slide_prior.addClass('current').css('left', '-100%').stop().animate
      left: '0%'
    , 666, 'easeInOutExpo', =>
      @$ctrl.on Legwork.touchstart, @nextSlide
      Legwork.$doc.on 'keyup.slider', @handleArrowKeys

  ###
  *------------------------------------------*
  | handleArrowKeys:void (=)
  |
  | Determine wich direction to slide
  | based on left or right arrow key hit
  *----------------------------------------###
  handleArrowKeys: (e) =>
    kc = e.keyCode

    if kc is 39
      @nextSlide()

    if kc is 37
      @priorSlide()









    