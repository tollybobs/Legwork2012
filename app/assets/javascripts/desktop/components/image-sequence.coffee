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
    @interval = Math.round(1000 / @fps)
    @current_frame = 0

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
    @$el.trigger('sequence_init')

  ###
  *------------------------------------------*
  | play:void (=)
  |
  | Play the sequence.
  *----------------------------------------###
  play: =>
    # Is it done yet, daaaaang
    if @current_frame is @img_len
      @$el.trigger('sequence_complete')
    else
      @current_frame++
      @continue()

  ###
  *------------------------------------------*
  | continue:void (=)
  |
  | Continue to the next frame.
  *----------------------------------------###
  continue: =>
    #@$imgs.css('visibility', 'hidden')
    #@$imgs.eq(@current_frame - 1).css('visibility', 'visible')

    @$imgs.attr('src', @img_arr[@current_frame - 1])

    # Trigger frame event
    @$el.trigger('sequence_frame')

    @img_timeout = setTimeout(@play, @interval)

  ###
  *------------------------------------------*
  | stop:void (-)
  |
  | Staaaaahp.
  *----------------------------------------###
  stop: ->
    @$imgs.css('visibility', 'hidden')
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