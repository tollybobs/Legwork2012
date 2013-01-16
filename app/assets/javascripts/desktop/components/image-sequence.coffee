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
    @img_arr = init_obj.settings.frames
    @img_len = @img_arr.length
    @fps = init_obj.settings.fps
    @current_frame = 0
    @current_time  = @rightNow()

    @build()

    # Fire it up
    @img_frame = requestAnimationFrame(@play)

  ###
  *------------------------------------------*
  | build:void (-)
  |
  | Q: When is now? A: This is now.
  *----------------------------------------###
  rightNow: ->
    if window['performance']? and window['performance']['now']?
      return window['performance']['now']()
    else
      return +(new Date())

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
    @$el.trigger('sequence_init')

  ###
  *------------------------------------------*
  | play:void (=)
  |
  | Play the sequence.
  *----------------------------------------###
  play: =>
    time = @rightNow()
    delta = (time - @current_time) / 1000
    @current_frame += (delta * @fps)
    frame_num = Math.floor(@current_frame)

    console.log(delta, frame_num)

    if frame_num >= @img_len
      @$el.trigger('sequence_complete')
    else
      @$imgs.attr('src', @img_arr[frame_num - 1])
      @$el.trigger('sequence_frame')

      @img_frame = requestAnimationFrame(@play)
      @current_time = time


  ###
  *------------------------------------------*
  | stop:void (-)
  |
  | Staaaaahp.
  *----------------------------------------###
  stop: ->
    @$imgs.attr('src', '')
    cancelAnimationFrame(@img_frame)

  ###
  *------------------------------------------*
  | destroy:void (-)
  |
  | Big Gulps, eh?
  *----------------------------------------###
  destroy: ->
    @stop()
    @$view.remove()