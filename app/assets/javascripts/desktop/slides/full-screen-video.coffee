###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is still hot.

###

#= require ./slide

class Legwork.Slides.FullScreenVideo extends Legwork.Slides.Slide

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
    @$el = $(JST["desktop/templates/slides/full-screen-video"](@model))
    return @$el

  ###
  *------------------------------------------*
  | initialize:void (-)
  |
  | See Legwork.Slides.Slide initilaize
  *----------------------------------------###
  initialize: ->
    @ratio = 9 / 16
    @id = @model.id
    @$poster = $('.fs-poster', @$el)
    @$vimeo = $('.fs-iframe', @$el)

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
      Legwork.$wn.trigger('resize')
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
  | onResize:void (=)
  |
  | w:number - window width
  | h:number - window height
  |
  | Handle window resize
  *----------------------------------------###
  resize: (w, h) =>
    if (h / w) > @ratio
      @$vimeo.height h
      @$vimeo.width h / @ratio
    else
      @$vimeo.width w
      @$vimeo.height w * @ratio

    @$vimeo.css 'left', (w - @$vimeo.width()) / 2
    @$vimeo.css 'top', (h - @$vimeo.height()) / 2

  ###
  *------------------------------------------*
  |
  | Private Methods
  |
  *----------------------------------------###
  playVimeo: =>
    @$vimeo.empty().append("<iframe src='http://player.vimeo.com/video/#{@id}?title=0&amp;byline=0&amp;portrait=0&amp;badge=0&amp;color=ffffff&amp;autoplay=1' width='960' height='540' frameborder='0' webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>")

    @$poster.delay(333).fadeOut(666)