###

Copyright (c) 2012 Legwork Studio. All Rights Reserved.

###

#= require ./slide

class Legwork.Slides.TitleScreen extends Legwork.Slides.Slide

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
    @$el = @renderTemplate('title-screen', @model)
    @$bgvid = $('.bg-project-video', @$el)
    @$v = $('#' + @model.background.id)
    @$bgvid.append(@$v)

    return @$el

  ###
  *------------------------------------------*
  | initialize:void (-)
  |
  | See Legwork.Slides.Slide initilaize
  *----------------------------------------###
  initialize: ->
    @ratio = 9 / 16

  ###
  *------------------------------------------*
  | activate:void (-)
  |
  | Activate new/current slide
  *----------------------------------------###
  activate: ->
    Legwork.$wn.trigger('resize.detail')
    if @$bgvid.length > 0 and Legwork.supports_autoplay
      @$v[0].load()
      @$v[0].addEventListener 'canplaythrough', @playVideo, false
      @$v[0].addEventListener 'ended', @videoEnded, false

  ###
  *------------------------------------------*
  | deactivate:void (-)
  |
  | Deactivate old slide
  *----------------------------------------###
  deactivate: ->
    if @$bgvid.length > 0 and Legwork.supports_autoplay
      @$v[0].removeEventListener 'canplaythrough', @playVideo, false
      @$v[0].removeEventListener 'ended', @videoEnded, false

  ###
  *------------------------------------------*
  | onResize:void (=)
  |
  | w:number - window width
  | h:number - window height
  |
  | Handle window resize
  *----------------------------------------###
  resize: (w, h) =>
    if (h / w) > @ratio
      @$bgvid.height h
      @$bgvid.width h / @ratio
    else
      @$bgvid.width w
      @$bgvid.height w * @ratio

    @$bgvid.css 'left', (w - @$bgvid.width()) / 2
    @$bgvid.css 'top', (h - @$bgvid.height()) / 2

  ###
  *------------------------------------------*
  |
  | Private Methods
  |
  *----------------------------------------###

  ###
  *------------------------------------------*
  | playVideo:void (=)
  |
  | Set current time to 0
  | And play that video
  *----------------------------------------###
  playVideo: =>
    @$v[0].currentTime = 0
    @$v[0].play()

  ###
  *------------------------------------------*
  | videoEnded:void (=)
  |
  | Go ahead, play it again
  *----------------------------------------###
  videoEnded: =>
    @playVideo()