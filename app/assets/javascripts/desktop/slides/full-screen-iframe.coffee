###

Copyright (c) 2012 Legwork Studio. All Rights Reserved.

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
    super(options)

  ###
  *------------------------------------------*
  | build:$el (-)
  |
  | Build DOM based on model.
  *----------------------------------------###
  build: ->
    @$el = @renderTemplate('full-screen-iframe', @model)
    @$iframeWrapper = @$el.children(".iframe-wrapper")
    @$cover = @$el.children('.iframe-coverup')
    @url = @$el.data('url')
    return @$el

  ###
  *------------------------------------------*
  | activate:void (-)
  |
  | Activate new/current slide
  *----------------------------------------###
  activate: ->
    @$iframeWrapper.empty().append("<iframe src='#{@url}' height='100%' width='100%'></iframe>")
    setTimeout () => 
      console.log(@$cover)
      @$cover.fadeOut(1000)
    , 1000

  ###
  *------------------------------------------*
  | deactivate:void (-)
  |
  | Deactivate old slide
  *----------------------------------------###
  deactivate: ->
    $('iframe', @$el).hide()
    @$iframeWrapper.empty()
    @$cover.show()
