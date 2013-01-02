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
    @zone = options.zone
    @slug = options.slug

  ###
  *------------------------------------------*
  | build:$el (-)
  |
  | Build DOM based on model.
  *----------------------------------------###
  build: ->
    @$el = $(JST["desktop/templates/base-detail"]({model: @model, slug: @slug, zone: @zone}))
    @$related = $('#related-btn')
    @rel = @model.related

  ###
  *------------------------------------------*
  | initialize:void (-)
  |
  | Initialize slides after build
  *----------------------------------------###
  initialize: ->

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
      @$related.on Legwork.click, @switchProjects
      Legwork.$doc.on 'keyup.switch', @handleArrowKey
    , 333

    @$related.text(@model.upnext)

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

    @$related.off Legwork.click
    Legwork.$doc.off 'keyup.switch', @handleArrowKey

  ###
  *------------------------------------------*
  | switchProjects:void (=)
  |
  | Change url to show next related project
  *----------------------------------------###
  switchProjects: =>
    History.pushState(null, null, "/#{@zone}/#{@rel}")

  ###
  *------------------------------------------*
  | handleArrowKeys:void (=)
  |
  | if down, go to next project
  *----------------------------------------###
  handleArrowKey: (e) =>
    if e.keyCode is 40 then @switchProjects()
    if e.keyCode is 27 then $('#detail-close-btn').trigger(Legwork.click)





    