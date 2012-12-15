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
    @pro_tip = true
    @protime

  ###
  *------------------------------------------*
  | build:$el (-)
  |
  | Build DOM based on model.
  *----------------------------------------###
  build: ->
    @$el = $(JST["desktop/templates/#{@zone}-detail"]({model: @model, slug: @slug, zone: @zone}))

  ###
  *------------------------------------------*
  | initialize:void (-)
  |
  | Initialize slides after build
  *----------------------------------------###
  initialize: ->

  ###
  *------------------------------------------*
  | activate:void (-)
  |
  | Shows the element
  *----------------------------------------###
  activate: =>
    @pro_tip = true
    @showProTip()

    @$el.show()
    setTimeout =>
      @$el.addClass('open')
    , 0

  ###
  *------------------------------------------*
  | deactivate:void (-)
  |
  | Hides the element
  *----------------------------------------###
  deactivate: =>
    @$el.removeClass('open')
    setTimeout =>
      if @pro_tip is true then @removeProTip()
      @$el.hide()
    , 333

  ###
  *------------------------------------------*
  | showProTip:void (-)
  |
  | Show Pro Tip once
  *----------------------------------------###
  showProTip: =>
    $('#detail-pro-tip').show().addClass('instructor')

    Legwork.$doc.one Legwork.click, @removeProTip
    Legwork.$doc.one 'keyup.protip', @removeProTip

    @protime = setTimeout(@removeProTip, 6666)

  ###
  *------------------------------------------*
  | removeProTip:void (-)
  |
  | Remove Pro Tip after used once
  *----------------------------------------###
  removeProTip: =>
    @pro_tip = false

    clearTimeout(@protime)
    $('#detail-pro-tip').removeClass('instructor')

    setTimeout =>
      $('#detail-pro-tip').hide()
    , 333







    