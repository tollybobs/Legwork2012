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

  ###
  *------------------------------------------*
  | build:$el (-)
  |
  | Build DOM based on model.
  *----------------------------------------###
  build: ->
    @$el = $(JST["desktop/templates/base-detail"]({model: @model, slug: @slug}))
    @$related = $('#related-btn')
    @rel = @model.related

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
  | activate:void (=)
  |
  | Shows the element
  *----------------------------------------###
  activate: =>
    @$el.show()
    setTimeout =>
      @$el.addClass('open')
      
      if @model.related
        @$related.on Legwork.click, @switchProjects
        Legwork.$doc.on 'keyup.switch', @handleArrowKey
    , 333

    if @model.related then @$related.text(@model.upnext)

  ###
  *------------------------------------------*
  | deactivate:void (=)
  |
  | Hides the element
  *----------------------------------------###
  deactivate: =>
    @$el.removeClass('open')
    setTimeout =>
      @$el.hide()
    , 333

    if @model.related
      @$related.off Legwork.click
      Legwork.$doc.off 'keyup.switch', @handleArrowKey

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
  | handleArrowKeys:void (=)
  |
  | if down, go to next project
  *----------------------------------------###
  handleArrowKey: (e) =>
    if e.keyCode is 40 then @switchProjects()
    if e.keyCode is 27 then $('#detail-close-btn').trigger(Legwork.click)





    