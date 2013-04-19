###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is still hot.

###

#= require ./slide

class Legwork.Slides.FullScreenIframe extends Legwork.Slides.Slide

  ###
  *------------------------------------------*
  | constructor:void (-)
  |
  | options:object - initialization object
  |
  | Construct the fuggin' thing.
  *----------------------------------------###
  constructor: (options) ->
    # POWERFUL!
    super(options)

  ###
  *------------------------------------------*
  | build:$el (-)
  |
  | Build DOM based on model.
  *----------------------------------------###
  build: ->
    @$el = @renderTemplate('full-screen-iframe', @model)
    @url = @$el.data('url')
    return @$el

  ###
  *------------------------------------------*
  | activate:void (-)
  |
  | Activate new/current slide
  *----------------------------------------###
  activate: ->
    @$el.empty().append("<iframe src='#{@url}' height='100%' width='100%'></iframe>")

  ###
  *------------------------------------------*
  | deactivate:void (-)
  |
  | Deactivate old slide
  *----------------------------------------###
  deactivate: ->
    $('iframe', @$el).fadeOut 333, =>
      @$el.empty()





