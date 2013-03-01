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
    @$loader = $('#loader-content', @$view)
    @$gif = $('.gif', @$view)
    @fill_time
    @rgba = @$gif.data('rgba')
    console.log(@rgba)

    # wait for img to be preloaded
    @$gif.one 'load', (e) =>
      @$loader.fadeIn 666, =>
        @initCanvas()
        super()

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



  initCanvas: () =>
    @canvas = document.getElementById('canvas-fill')
    @canvas.width = @$loader.innerWidth()
    @canvas.height = @$loader.innerHeight()
    @cw = @canvas.width
    @ch = @canvas.height

    @ctx = @canvas.getContext('2d')
    @ctx.strokeStyle = "rgba(#{@rgba})"
    @ctx.lineWidth = 4

    @ctx.drawImage(@canvas, 0, 0)

    @sectors = Math.PI * @$loader.width() # 1400
    @current_sector = 0

    @radians = (deg) =>
      return (Math.PI / 180) * deg

    @get_tick = (num) =>
      console.log(num)
      @tick = @radians(360) / @sectors
      return @tick * num

    @sector = (start, end) =>
      start = @get_tick(@current_sector)
      end = @get_tick(@current_sector + 1)
      @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
      @ctx.drawImage(@canvas, 0, 0)
      @ctx.beginPath()
      @ctx.lineWidth = (Math.random() * 3) + 4
      @ctx.arc(@cw / 2, @ch / 2, (@cw / 2) - 10, 0, end)
      @ctx.stroke()
      @ctx.closePath()

    @fill_time = setInterval(@updateCanvasFill, 16)

  updateCanvasFill: =>
    if @current_sector < @destination
      @current_sector += 16
      @sector(@current_sector, @destination)
    if @current_sector is @destination
      clearInterval(@fill_time)

    


    # console.log(@current_sector, @destination, @percent)



  ###
  *------------------------------------------*
  | override loadComplete:void (-)
  |
  | Loading is finished, cycle status and
  | dispatch Legwork.loaded back to $el
  *----------------------------------------###
  loadComplete: ->
    clearInterval(@fill_time)
    setTimeout =>
      Legwork.$wrapper.show()

      @$view.stop().animate
        'opacity':0
      , 666, =>
        @$el.trigger('legwork_load_complete')
        @$view.remove()
    , 666


