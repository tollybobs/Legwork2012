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
    @fill_time

    # wait for img to be preloaded
    @$gif.one 'load', (e) =>
      @$loader.fadeIn 666, =>
        super()
        @initCanvas()

    if @$gif[0].complete is true
      @$gif.trigger('load')

  ###
  *------------------------------------------*
  | override updateProgress:void (-)
  |
  | Updated the view w/ percent loaded.
  *----------------------------------------###
  updateProgress: () ->
    super()

    @destination = Math.ceil(@sectors * (@percent / 100))
    @updateCanvasFill()

  ###
  *------------------------------------------*
  | initCanvas:void (=)
  |
  | Set up canvas to draw a circle
  | based on percent loaded
  *----------------------------------------###
  initCanvas: () =>
    @canvas = document.getElementById('canvas-fill')
    @ctx = @canvas.getContext('2d')
    @step = 0
    @fill_percent = 0

    @canvas.width = @$loader.width()
    @canvas.height = @$loader.height()
    @ctx.strokeStyle = "#eeeeee"
    @ctx.lineWidth = 5

    window.requestAnimationFrame(@render);
    setTimeout @updateProgress, 100

  render: () =>
    @step += 0.01

    if @step >= 1.01
      # load complete
      @loadComplete()
    else if @step >= @fill_percent
      # nothing is cool
      @step -= 0.01
      window.requestAnimationFrame(@render)
    else
      # get rad
      rad = ((360 * @step) * (Math.PI / 180))
      x = (@canvas.width / 2) + ((@canvas.width / 2) - 20) * Math.cos(rad)
      y = (@canvas.height / 2) + ((@canvas.width / 2) - 20) * Math.sin(rad)
      i = 0
      
      @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
      while i < 20
        @ctx.lineTo (x + Math.round((Math.random() * 16) - 6)), (y + Math.round((Math.random() * 16) - 6))
        @ctx.stroke()
        i++

      window.requestAnimationFrame(@render)

  updateProgress: () =>
    @fill_percent += 0.01
    
    if @fill_percent < 1
      setTimeout @updateProgress, 100

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


