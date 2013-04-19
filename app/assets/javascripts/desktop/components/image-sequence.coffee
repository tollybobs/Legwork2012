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
    @frames = init_obj.settings.frames
    @fresh = Modernizr.canvas
    @total_frames = @frames.length
    @fps = init_obj.settings.fps
    @current_frame = 0

    # Render engine
    if @fresh is true
      @render_ref = @render
    else
      @render_ref = @renderForTheAncientTimes

    # Build
    @build()

    # Trigger init
    @$el.trigger('sequence_init')

    # Fire it up
    @current_time  = @rightNow()
    @img_frame = window.requestAnimationFrame(@play)

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
  | Build.
  *----------------------------------------###
  build: ->
    @$view = $('<div class="image-sequence-wrap" />').appendTo(@$el)

    if @fresh is true
      @cnv = document.createElement('canvas')
      @cnv.width = @frames[0].width
      @cnv.height = @frames[0].height
      @ctx = @cnv.getContext('2d')
      @$view.html(@cnv)
    else
      @$si = $('<img class="sequence-item" src="">').appendTo(@$view)

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

    if frame_num >= @total_frames
      @$el.trigger('sequence_complete')
    else
      # Render
      @render_ref(frame_num)

      # Trigger frame
      @$el.trigger('sequence_frame')

      @img_frame = requestAnimationFrame(@play)
      @current_time = time

  ###
  *------------------------------------------*
  | render:void (-)
  |
  | frame:integer - current frame
  |
  | Render the current frame.
  *----------------------------------------###
  render: (frame) ->
    @ctx.clearRect(0, 0, @cnv.width, @cnv.height)
    @ctx.drawImage(@frames[frame], 0, 0)

  ###
  *------------------------------------------*
  | renderForTheAncientTimes:void (-)
  |
  | frame:integer - current frame
  |
  | Render for no canvas support.
  *----------------------------------------###
  renderForTheAncientTimes: (frame) ->
    @$si.attr('src', @frames[frame].src)

  ###
  *------------------------------------------*
  | stop:void (-)
  |
  | Staaaaahp.
  *----------------------------------------###
  stop: ->
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