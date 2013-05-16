###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is hot.

###

class Legwork.Controllers.BaseDetail

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
    @slug = options.slug
    @$pro_tip = []

  ###
  *------------------------------------------*
  | build:$el (-)
  |
  | Build DOM based on model.
  *----------------------------------------###
  build: ->
    @$el = $(JST["desktop/templates/base-detail"]({model: @model, slug: @slug}))
    @$detail_inner = $('#detail-inner')
    @$related = $('#related-btn')
    @rel = @model.related

    $slides_wrap = @$el.find('.slides')
    html = ''

    for slide in @model.slides
      slide_view = new Legwork.Slides[slide.type]({model: slide})
      $slides_wrap.append(slide_view.build())
      @slide_views.push(slide_view)

    @$slides = $('.slide', @$el)

  ###
  *------------------------------------------*
  | initialize:void (-)
  |
  | Initialize slides after build
  *----------------------------------------###
  initialize: ->
    if @model.related then @$related.show()
    else @$related.hide()

  ###
  *------------------------------------------*
  | activate:void (-)
  |
  | Shows the element
  *----------------------------------------###
  activate: ->
    @$el.show()
    setTimeout =>
      @$el.addClass('open')

      if @model.related
        @$related.on Legwork.click, @switchProjects
        Legwork.$doc.on 'keyup.switch', @handleArrowKey
    , 333

    if @model.related then @$related.text(@model.related_name)

    @onResize = _.debounce(@afterResize, 300)
    Legwork.$wn.on('resize.detail', @onResize)

  ###
  *------------------------------------------*
  | deactivate:void (-)
  |
  | Hides the element
  *----------------------------------------###
  deactivate: ->
    @$el.removeClass('open')
    setTimeout =>
      @$el.hide()
    , 333

    if @model.related
      @$related.off Legwork.click
      Legwork.$doc.off 'keyup.switch', @handleArrowKey

    Legwork.$wn.off('resize.detail', @onResize)

  ###
  *------------------------------------------*
  | afterResize:void (=)
  |
  | Call after resize complete
  *----------------------------------------###
  afterResize: =>

  ###
  *------------------------------------------*
  | switchProjects:void (=)
  |
  | Change url to show next related project
  *----------------------------------------###
  switchProjects: =>
    History.pushState(null, null, "/#{@rel}")

  ###
  *------------------------------------------*
  | switchProjects:void (-)
  |
  | Change url to show next related project
  *----------------------------------------###
  hintThereIsNoMore: ->
    @$detail_inner.addClass('bump')

    setTimeout =>
      @$detail_inner.removeClass('bump')
    , 150

  ###
  *------------------------------------------*
  | handleArrowKeys:void (=)
  |
  | e:object - event object
  |
  | if down, go to next project
  *----------------------------------------###
  handleArrowKey: (e) =>
    if e.keyCode is 27 then $('#detail-close-btn').trigger(Legwork.click)
    if e.keyCode is 40 then @switchProjects()
    if e.keyCode is 38
      if @model.related
        state = History.getState()
        url = state.hash.replace(/[^a-z0-9_-]+/gi, '')

        if url? and url is Legwork.open_detail_state then @hintThereIsNoMore()
        else History.back()