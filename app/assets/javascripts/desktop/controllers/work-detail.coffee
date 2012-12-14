###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is hot.

###

class Legwork.WorkDetail extends Legwork.Controllers.BaseDetail

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
    @protime

  ###
  *------------------------------------------*
  | build:$el (-)
  |
  | Build DOM based on model.
  *----------------------------------------###
  build: ->
    super()

    # title_screen = new Legwork.Slides.TitleScreen({model: @model, $el: $('.title-screen', @$el)})
    # @slide_views.push(title_screen)

    $slides_wrap = @$el.find('.slides')

    for slide in @model.slides
      slide_view = new slide.type({model: slide})
      $slides_wrap.append slide_view.build()
      @slide_views.push(slide_view)

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
    super()

    @current_slide_view = @slide_views[0]
    @current_slide_view.activate()

    @$el.find('.title-screen').css('left','0%')
    @$el.find('.next-slide-btn').remove()

    # @onResize = _.debounce(@afterResize, 300)
    # Legwork.$wn.on('resize', @onResize)

  ###
  *------------------------------------------*
  | deactivate:void (-)
  |
  | Hides the element
  *----------------------------------------###
  deactivate: ->
    super()

    @current_slide_view.deactivate()

    @$el.find('.title-screen').css('left','100%')
    # Legwork.$wn.off('resize', @onResize)

  ###
  *------------------------------------------*
  | afterResize:void (-)
  |
  | Call after resize complete
  *----------------------------------------###
  # afterResize: =>
  #   w = Legwork.$wn.width()
  #   h = Legwork.$wn.height()
  #   @current_slide_view.resize(w, h)

  ###
  *------------------------------------------*
  | showProTip:void (-)
  |
  | Show Pro Tip once
  *----------------------------------------###
  showProTip: ->
    if Legwork.pro_tip is true
      $('#detail-pro-tip').addClass('instructor')

      Legwork.$doc.one Legwork.click, @removeProTip
      Legwork.$doc.one 'keyup.protip', @removeProTip

      @protime = setTimeout(@removeProTip, 6000)

  ###
  *------------------------------------------*
  | removeProTip:void (-)
  |
  | Remove Pro Tip after used once
  *----------------------------------------###
  removeProTip: ->
    if Legwork.pro_tip is true
      Legwork.pro_tip = false

      clearTimeout(@protime)
      $('#detail-pro-tip').removeClass('instructor')

      setTimeout =>
        $('#detail-pro-tip').remove()
      , 333










