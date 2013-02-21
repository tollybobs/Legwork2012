###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is still hot.

###

class Legwork.Slides.Slide

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
    @$el = options.$el

  ###
  *------------------------------------------*
  | build:$el (-)
  |
  | Build DOM based on model.
  *----------------------------------------###
  build: ->

  ###
  *------------------------------------------*
  | initialize:void (-)
  |
  | Initialize after build and attached to DOM.
  *----------------------------------------###
  initialize: ->

  ###
  *------------------------------------------*
  | activate:void (-)
  |
  | Activate the slide
  *----------------------------------------###
  activate: ->

  ###
  *------------------------------------------*
  | deactivate:void (-)
  |
  | Deactivate the slide
  *----------------------------------------###
  deactivate: ->

  ###
  *------------------------------------------*
  | onResize:void (-)
  |
  | w:number - window width
  | h:number - window height
  |
  | Handle window resize
  *----------------------------------------###
  resize: (w, h) ->


  ###
  *------------------------------------------*
  | render template:void (-)
  |
  | Clean white space to render templates
  *----------------------------------------###
  renderTemplate: (template, context) ->
    $.parseHTML((JST["desktop/templates/slides/#{template}"](context)))


