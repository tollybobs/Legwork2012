###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is hot.

###
class Legwork.CaseStudyDetail extends Legwork.Controllers.BaseDetail

  ###
  *------------------------------------------*
  | constructor:void (-)
  |
  | options:object - initialization object
  |
  | Construct the fuggin' thing.
  *----------------------------------------###
  constructor: (options) ->
    super(options)

    # Class vars
    @slide_views = []

  ###
  *------------------------------------------*
  | build:$el (-)
  |
  | Build DOM based on model.
  *----------------------------------------###
  build: ->
    super()

    $slides_wrap = @$el.find('.slides')
    @$next_btn = @$el.find('.next-slide-btn')
    @$back_btn = @$el.find('#back-slide-btn')
    @$current_cnt = @$el.find('.current-cnt')
    @inmotion

    for slide in @model.slides
      slide_view = new Legwork.Slides[slide.type]({model: slide})
      $slides_wrap.append slide_view.build()
      @slide_views.push(slide_view)

    @$slides = $('.slide', @$el)

    return @$el

  ###
  *------------------------------------------*
  | initialize:void (-)
  |
  | Initialize slides after build
  *----------------------------------------###
  initialize: ->
    super()

    for view in @slide_views
      view.initialize()

  ###
  *------------------------------------------*
  | activate:void (-)
  |
  | Shows the element
  *----------------------------------------###
  activate: ->
    super()

    @turnOffKeyboardNav()

    @current_slide_view = @slide_views[0]
    @current_slide_index = 0
    @current_slide_view.activate()

    @resetSlides()

    @$next_btn.on Legwork.click, @nextSlide
    @$back_btn.on Legwork.click, @priorSlide
    $('.project-callouts h4', @$el).on Legwork.click, =>
      @$next_btn.trigger Legwork.click

    if Legwork.pro_tip is true and Legwork.app_width > 740
      Legwork.pro_tip = false

      @$pro_tip = $(JST["desktop/templates/pro-tip"]({}))

      @$pro_tip
        .appendTo(@$slides.eq(0))
        .one('click', @removeProTip)

      @protime = setTimeout(@removeProTip, 4000)

  ###
  *------------------------------------------*
  | deactivate:void (-)
  |
  | Hides the element
  *----------------------------------------###
  deactivate: ->
    super()

    @current_slide_view.deactivate()

    if @inmotion then return false
    else @inmotion is true

    @$next_btn.off Legwork.click
    @$back_btn.off Legwork.click
    $('.project-callouts h4', @$el).off Legwork.click

    setTimeout(=>
      if @$pro_tip.length isnt 0
        @$pro_tip.remove()
        clearTimeout(@protime)
    , 500)

    @turnOffKeyboardNav()

  ###
  *------------------------------------------*
  | resetSlides:void (-)
  |
  | Reset the slides so that the
  | title-screen slide is first/current
  *----------------------------------------###
  resetSlides: =>
    @$slides
      .removeClass('current')
      .css('margin-left', '100%')

    @$slides.eq(@current_slide_index)
      .addClass('current')
      .css('margin-left', '0%')
      .show()

    @$current_cnt.text(@current_slide_index + 1)
    @$el.find('.total-cnt').text(@slide_views.length)

    @$back_btn.css 'top','-50px'

  ###
  *------------------------------------------*
  | removeProTip:void (=)
  |
  | Get rid of the pro tip.
  *----------------------------------------###
  removeProTip: =>
    @$pro_tip.animate({
      'left': '-100%'
    }, 666, 'easeInOutExpo', (e) =>
      @$pro_tip.remove()
    )

  ###
  *------------------------------------------*
  | afterResize:void (=)
  |
  | Call after resize complete
  *----------------------------------------###
  afterResize: =>
    w = Legwork.$wn.width()
    h = Legwork.$wn.height()
    @current_slide_view.resize(w, h)

    if w <= 740

      if @current_slide_index isnt 0
        @current_slide_view.deactivate()
        @current_slide_index = 0
        @current_slide_view = @slide_views[@current_slide_index]
        @current_slide_view.activate()
        @resetSlides()

      if @handlingArrowKeys is true then @turnOffKeyboardNav()
    else
      if @handlingArrowKeys is false then @turnOnKeyboardNav()

  ###
  *------------------------------------------*
  | nextSlide:void (=)
  |
  | e:object - event object
  |
  | Next. Next slide.
  *----------------------------------------###
  nextSlide: (e) =>
    if @inmotion then return false
    else @inmotion = true

    @old_slide_index = @current_slide_index
    @old_slide_view = @current_slide_view

    @current_slide_index = if @current_slide_index < @slide_views.length - 1 then @current_slide_index + 1 else 0
    @current_slide_view = @slide_views[@current_slide_index]
    @current_slide_view.activate()

    @$current_cnt.text(@current_slide_index + 1)

    @$slides.css('margin-left','100%')
    @current_slide_view.$el.addClass('current').css({'margin-left': '0%', 'z-index': '1'}).show()
    @old_slide_view.$el.removeClass('current').css({'margin-left':'0%', 'z-index':'2'}).stop().animate
      'margin-left': '-100%'
    , 666, 'easeInOutExpo', =>
      @old_slide_view.$el.hide()
      @old_slide_view.deactivate()

      if @$pro_tip.length isnt 0
        @$pro_tip.remove()
        clearTimeout(@protime)

      if @current_slide_index is 1
        @$back_btn.css 'top','0px'

      @inmotion = false

  ###
  *------------------------------------------*
  | priorSlide:void (=)
  |
  | e:object - event object
  |
  | Prior. Prior slide.
  *----------------------------------------###
  priorSlide: (e) =>
    if @inmotion then return false
    else @inmotion = true

    @old_slide_index = @current_slide_index
    @old_slide_view = @current_slide_view

    @current_slide_index = if @current_slide_index > 0 then @current_slide_index - 1 else @slide_views.length - 1
    @current_slide_view = @slide_views[@current_slide_index]
    @current_slide_view.activate()

    @$current_cnt.text(@current_slide_index + 1)

    if @current_slide_index is 0
      @$back_btn.css 'top','-50px'

    @$slides.css('margin-left','100%')
    @old_slide_view.$el.removeClass('current').css({'margin-left': '0%', 'z-index': '1'})
    @current_slide_view.$el.addClass('current').css({'margin-left':'-100%', 'z-index':'2'}).show().stop().animate
      'margin-left': '-0%'
    , 666, 'easeInOutExpo', =>
      @old_slide_view.$el.hide()
      @old_slide_view.deactivate()

      if @$pro_tip.length isnt 0
        @$pro_tip.remove()
        clearTimeout(@protime)

      @inmotion = false

  ###
  *------------------------------------------*
  | handleArrowKeys:void (=)
  |
  | e:object - event object
  |
  | Determine wich direction to slide
  | based on left or right arrow key hit
  *----------------------------------------###
  handleArrowKeys: (e) =>
    kc = e.keyCode

    if kc is 37
      e.preventDefault()
      @$back_btn.trigger('click')

    if kc is 39
      e.preventDefault()
      @$next_btn.trigger('click')

  ###
  *------------------------------------------*
  | turnOffKeyboardNav:void (=)
  |
  | Turn off keyboard nav
  *----------------------------------------###
  turnOffKeyboardNav: =>
    @handlingArrowKeys = false
    Legwork.$doc.off 'keyup.slider', @handleArrowKeys

  ###
  *------------------------------------------*
  | turnOnKeyboardNav:void (=)
  |
  | Turn on keyboard nav
  *----------------------------------------###
  turnOnKeyboardNav: =>
    @handlingArrowKeys = true
    Legwork.$doc.on 'keyup.slider', @handleArrowKeys