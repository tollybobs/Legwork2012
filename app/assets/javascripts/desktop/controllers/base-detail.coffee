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
    @protime

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
    @$pro_tip = $('#detail-pro-tip')
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

      if Legwork.pro_tip is true
        @_showProTip()
    , 333

    if @model.related then @$related.text(@model.related_name)

  ###
  *------------------------------------------*
  | deactivate:void (=)
  |
  | Hides the element
  *----------------------------------------###
  deactivate: =>
    @$el.removeClass('open')
    setTimeout =>
      if Legwork.pro_tip is true then @_removeProTip()
      @$el.hide()
    , 333

    if @model.related
      @$related.off Legwork.click
      Legwork.$doc.off 'keyup.switch', @handleArrowKey

  ###
  *------------------------------------------*
  | _showProTip:void (=)
  |
  | Show Pro Tip once
  *----------------------------------------###
  _showProTip: =>
    @$pro_tip.addClass 'instructor'

    Legwork.$doc.one Legwork.click, =>
      if @$pro_tip.hasClass 'instructor' then @_removeProTip()

    @protime = setTimeout(@_removeProTip, 6666)

  ###
  *------------------------------------------*
  | _removeProTip:void (=)
  |
  | Remove Pro Tip after used once
  *----------------------------------------###
  _removeProTip: =>
    Legwork.pro_tip = false
    
    clearTimeout(@protime)

    @$pro_tip.removeClass 'instructor'

    setTimeout =>
      @$pro_tip.remove()
    , 333

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
  | switchProjects:void (=)
  |
  | Change url to show next related project
  *----------------------------------------###
  hintThereIsNoMore: =>
    @$detail_inner.addClass('bump')

    setTimeout =>
      @$detail_inner.removeClass('bump')
    , 150

  ###
  *------------------------------------------*
  | handleArrowKeys:void (=)
  |
  | if down, go to next project
  *----------------------------------------###
  handleArrowKey: (e) =>
    if @$pro_tip.hasClass 'instructor' then @_removeProTip()

    if e.keyCode is 27 then $('#detail-close-btn').trigger(Legwork.click)
    if e.keyCode is 40 then @switchProjects()
    if e.keyCode is 38
      if @model.related
        state = History.getState()
        url = state.hash.replace(/^\/|\.|\#/g, '')

        if url? and url is Legwork.open_detail_state then @hintThereIsNoMore()
        else History.back()