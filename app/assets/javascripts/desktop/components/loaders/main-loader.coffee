###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is hot.

###

class Legwork.MainLoader extends Legwork.Loader

  ###
  *------------------------------------------*
  | override constructor:void (-)
  |
  | initObj:object - items to load, etc.
  |
  | Construct the fuggin' thing.
  *----------------------------------------###
  constructor: (initObj) ->
    super(initObj)

  ###
  *------------------------------------------*
  | override build:void (-)
  |
  | DOM manipulations, instantiations, etc.
  *----------------------------------------###
  build: ->
    imgs = Legwork.Home.preloader.images
    img = imgs[Math.floor(Math.random()* imgs.length)]

    @$view = $(JST['desktop/templates/main-loader']({image: img}))
    @$el.append(@$view)

    # Loader view DOM refs
    @$loader = $('#loader-holder', @$view)
    @$gif = $('.gif', @$view)
    @$progress = $('#main-loader-progress')

    # wait for img to be preloaded
    @$gif.one 'load', (e) =>
      @$loader.fadeIn 666, =>
        super()

    if @$gif[0].complete is true
      @$gif.trigger('load')

  ###
  *------------------------------------------*
  | override updateProgress:void (-)
  |
  | Updated the view w/ percent loaded.
  *----------------------------------------###
  updateProgress: ->
    super()

    @$progress.text('GIVN\'R ' + Math.round((@percent / 100) * 110) + '%')

  ###
  *------------------------------------------*
  | override loadComplete:void (-)
  |
  | Loading is finished, cycle status and
  | dispatch Legwork.loaded back to $el
  *----------------------------------------###
  loadComplete: ->
    setTimeout =>
      Legwork.$wrapper.show()

      @$view.stop().animate
        'opacity':0
      , 666, =>
        @$el.trigger('legwork_load_complete')
        @$view.remove()
    , 333