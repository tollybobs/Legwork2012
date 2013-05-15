###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is still hot.

###

#= require ./slide

class Legwork.Slides.PanningSlide extends Legwork.Slides.Slide

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
    @$el = @renderTemplate('panning', @model)
    return @$el

  ###
  *------------------------------------------*
  | initialize:void (-)
  |
  | See Legwork.Slides.Slide
  *----------------------------------------###
  initialize: ->
    @$pan_image = $('.pan-image', @$el)
    @pw = @$pan_image.width()
    @ph = @$pan_image.height()

    # reset image to center before triggering resize
    # because the throttle delay is seen as you slide this into view..
    @$pan_image
      .css
        'top': '0px'
        'left':  (Legwork.$wn.width() / 2) - (@pw / 2) + 'px'

    @initPanning()

  ###
  *------------------------------------------*
  | activate:void (-)
  |
  | Activate new/current slide
  *----------------------------------------###
  activate: ->
    Legwork.$wn.trigger('resize.detail')
    @$pan_image.removeClass('constrain')

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
    @bw = w
    @bh = h
    @horz_center = (@bw / 2) - (@pw / 2)
    @vert_center = (@bh / 2) - (@ph / 2)
    @resetToCenter()

  ###
  *------------------------------------------*
  |
  | Private Methods
  |
  *----------------------------------------###
  resetToCenter: =>
    @$pan_image
      .css
        'top': '0px'
        'left':  @horz_center + 'px'

  initPanning: =>
    @$pan_image
      .on Legwork.mousedown, (e) =>
        $t = $(e.currentTarget)

        $t.removeClass('constrain').addClass('grabbing').data('pan',
          'iMouseX': e.pageX
          'iMouseY': e.pageY
          'iPosX': $t.position().left
          'iPosY': $t.position().top
        ).on(Legwork.mousemove, @_clickedDrag)

        Legwork.$doc.one(Legwork.mouseup, @_constrainDrag)
        e.preventDefault()

  _clickedDrag: (e) =>
    data = $(e.currentTarget).data('pan')
    deltaX = e.pageX - data.iMouseX
    deltaY = e.pageY - data.iMouseY
    normalX = deltaX + data.iPosX
    normalY = deltaY + data.iPosY

    if @bw >= @pw then normalX = @horz_center + 'px'
    if @bh >= @ph then normalY = @vert_center + 'px'

    @$pan_image
      .css
        'top': normalY + 'px'
        'left': normalX + 'px'

  _constrainDrag: =>
    pX = @$pan_image.position().left
    pY = @$pan_image.position().top
    bX = @bw - @pw
    bY = @bh - @ph
    x = pX
    y = pY

    @$pan_image.unbind(Legwork.mousemove, @_clickedDrag).addClass('constrain').removeClass('grabbing')

    if pX > 0 then x = 0
    if pY > 0 then y = 0
    if pX < bX then x = bX
    if pY < bY then y = bY
    if @bw >= @pw then x = @horz_center
    if @bh >= @ph then y = @vert_center

    @$pan_image
      .css
        'top': y + 'px'
        'left': x + 'px'