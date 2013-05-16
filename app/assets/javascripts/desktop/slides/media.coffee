###

Copyright (c) 2012 Legwork Studio. All Rights Reserved.

###

#= require ./slide

class Legwork.Slides.Media extends Legwork.Slides.Slide

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
    @$el = @renderTemplate('media', @model)
    return @$el

  ###
  *------------------------------------------*
  | initialize:void (-)
  |
  | See Legwork.Slides.Slide initilaize
  *----------------------------------------###
  initialize: ->
    if @model.media.type is 'vimeo'
      @id = @model.media.id
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
    if @model.media.type is 'vimeo'
      @$poster
        .show()
        .on Legwork.click, @playVimeo

  ###
  *------------------------------------------*
  | deactivate:void (-)
  |
  | Deactivate old slide
  *----------------------------------------###
  deactivate: ->
    if @model.media.type is 'vimeo'
      @$vimeo.empty()
      @$poster
        .hide()
        .off Legwork.click, @playVimeo

  ###
  *------------------------------------------*
  |
  | Private Methods
  |
  *----------------------------------------###

  ###
  *------------------------------------------*
  | fetchVimeoThumbnail:void (=)
  |
  | Fetch vimeo thumbnail for poster
  *----------------------------------------###
  fetchVimeoThumbnail: =>
    $.getJSON "http://www.vimeo.com/api/v2/video/#{@id}.json?callback=?", {format: "json"}, (data) =>
      @$poster.append("<img src='#{data[0].thumbnail_large}' alt='' /><div class='vimeo-play-btn'></div>")

  ###
  *------------------------------------------*
  | playVimeo:void (=)
  |
  | Append video and autoplay it
  *----------------------------------------###
  playVimeo: =>
    @$vimeo.empty().append("<iframe src='http://player.vimeo.com/video/#{@id}?title=0&amp;byline=0&amp;portrait=0&amp;badge=0&amp;color=ffffff&amp;autoplay=1' width='730' height='411' frameborder='0' webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>")
    @$poster.delay(333).fadeOut(666)