###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is still hot.

###

#= require ./slide

class Legwork.Slides.Video extends Legwork.Slides.Slide

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
    @$el = @renderTemplate('video', @model)
    return @$el

  ###
  *------------------------------------------*
  | initialize:void (-)
  |
  | See Legwork.Slides.Slide initilaize
  *----------------------------------------###
  initialize: ->
    @id = @model.id
    @$poster = $('.vimeo-poster', @$el)
    @$vimeo = $('.vimeo-iframe', @$el)
    @fetchVimeoThumbnail()

  ###
  *------------------------------------------*
  | activate:void (-)
  |
  | Activate new/current slide
  *----------------------------------------###
  activate: ->
    @$poster
      .show()

    setTimeout =>
      @playVimeo()
    , 666

  ###
  *------------------------------------------*
  | deactivate:void (-)
  |
  | Deactivate old slide
  *----------------------------------------###
  deactivate: ->
    @$vimeo.empty()
    @$poster
      .hide()

  ###
  *------------------------------------------*
  |
  | Private Methods
  |
  *----------------------------------------###
  fetchVimeoThumbnail: =>
    $.getJSON "http://www.vimeo.com/api/v2/video/#{@id}.json?callback=?", {format: "json"}, (data) =>
      @$poster.append("<img src='#{data[0].thumbnail_large}' alt='' />")

  playVimeo: =>
    @$vimeo.empty().append("<iframe src='http://player.vimeo.com/video/#{@id}?title=0&amp;byline=0&amp;portrait=0&amp;badge=0&amp;color=ffffff&amp;autoplay=1' width='730' height='411' frameborder='0' webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>")
    @$poster.delay(333).fadeOut(666)



