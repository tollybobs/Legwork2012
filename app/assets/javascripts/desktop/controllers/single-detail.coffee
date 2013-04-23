###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is hot.

###

class Legwork.SingleDetail extends Legwork.Controllers.BaseDetail

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

    for slide in @model.slides
      slide_view = new Legwork.Slides[slide.type]({model: slide})
      $slides_wrap.append slide_view.build()
      @slide_views.push(slide_view)

    @$slides = @$el.find('.slide')

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

    @current_slide_view = @slide_views[0]
    @current_slide_view.activate()

    @$slides.first().css('left','0%').show()
    @$el.find('.next-slide-btn').remove()

  ###
  *------------------------------------------*
  | deactivate:void (-)
  |
  | Hides the element
  *----------------------------------------###
  deactivate: ->
    super()

    @current_slide_view.deactivate()

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