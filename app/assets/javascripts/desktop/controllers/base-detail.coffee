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
    , 333

    @$related.on Legwork.click, @jumpToRelatedProject

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

  ###
  *------------------------------------------*
  | jumpToRelatedProject:void (=)
  |
  | Change url to show next related project
  *----------------------------------------###
  jumpToRelatedProject: =>
    related = @model.related
    href = "/#{@zone}/#{related}"

    History.pushState(null, null, href)






    