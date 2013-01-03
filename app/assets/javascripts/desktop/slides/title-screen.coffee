###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is still hot.

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
    # POWERFUL!
    super(options)

  ###
  *------------------------------------------*
  | build:$el (-)
  |
  | Build DOM based on model.
  *----------------------------------------###
  build: ->
    @$el = $(JST["desktop/templates/slides/title-screen"](@model))
    return @$el

  ###
  *------------------------------------------*
  | initialize:void (-)
  |
  | See Legwork.Slides.Slide initilaize
  *----------------------------------------###
  initialize: ->
    @ratio = 9 / 16
    @$bgvid = $('.bg-project-video', @$el)

  ###
  *------------------------------------------*
  | activate:void (-)
  |
  | Activate new/current slide
  *----------------------------------------###
  activate: ->
    Legwork.$wn.trigger('resize')

  ###
  *------------------------------------------*
  | deactivate:void (-)
  |
  | Deactivate old slide
  *----------------------------------------###
  deactivate: ->

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
    super(w, h)

    if (h / w) > @ratio
      @$bgvid.height h
      @$bgvid.width h / @ratio
    else
      @$bgvid.width w
      @$bgvid.height w * @ratio

    @$bgvid.css 'left', (w - @$bgvid.width()) / 2
    @$bgvid.css 'top', (h - @$bgvid.height()) / 2