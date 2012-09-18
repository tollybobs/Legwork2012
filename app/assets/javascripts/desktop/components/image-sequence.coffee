###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is hot.

###

class Legwork.ImageSequence

  ###
  *------------------------------------------*
  | constructor:void (-)
  |
  | initObj:object - init params
  |
  | Construct the fuggin' thing.
  *----------------------------------------###
  constructor: (init_obj) ->
    # Class vars
    @$el = init_obj.$el
    @img_arr = init_obj.settings.images
    @img_len = @img_arr.length
    @fps = init_obj.settings.fps
    @delay = if init_obj.settings.delay? then init_obj.settings.delay
    @interval = Math.round(1000 / @fps)
    @is_looping = init_obj.settings.is_looping or false
    @loops = if init_obj.settings.loops? then init_obj.settings.loops
    @current_frame = 0
    @current_loop = 0

    @build()

    # Fire it up
    @img_timeout = setTimeout(@play, @interval)

  ###
  *------------------------------------------*
  | build:void (-)
  |
  | DOM manipulations, instantiations, etc.
  *----------------------------------------###
  build: ->
    @$view = $(JST['desktop/templates/image-sequence']({img_arr: @img_arr}))
    @$el.append(@$view)

    # Collect
    @$imgs = @$el.find('.image-sequence-item')

    # Trigger init event
    @$el.trigger('Legwork.sequence_init')

  ###
  *------------------------------------------*
  | play:void (-)
  |
  | Play the sequence.
  *----------------------------------------###
  play: =>
    cont = true

    # Is it done yet, daaaaang
    if @current_frame is @img_len
      if @is_looping is true
        @current_frame = 0
        if @loops?
          @current_loop++
          if @current_loop is @loops
            @is_looping = false
      else
        cont = false
    else 
      @current_frame++

    if cont is true
      if @delay? then setTimeout(@continue, @delay) else @continue()
    else
      # Trigger complete event
      @$el.trigger('Legwork.sequence_complete')

  ###
  *------------------------------------------*
  | continue:void (-)
  |
  | Continue to the next frame.
  *----------------------------------------###
  continue: =>
    @$imgs.hide()
    @$imgs.eq(@current_frame - 1).show()

    @img_timeout = setTimeout(@play, @interval)

  ###
  *------------------------------------------*
  | stop:void (-)
  |
  | Stop the sequence.
  *----------------------------------------###
  stop: ->
    clearTimeout(@img_timeout)

  ###
  *------------------------------------------*
  | destroy:void (-)
  |
  | Big Gulps, eh?
  *----------------------------------------###
  destroy: ->
    @stop()
    @$view.remove()