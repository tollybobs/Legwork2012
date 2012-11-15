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
    @$el = $(JST["desktop/templates/slides/panning"](@model))
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

  ###
  *------------------------------------------*
  | activate:void (-)
  |
  | Activate new/current slide
  *----------------------------------------###
  activate: ->
    Legwork.$wn.trigger('resize')
    @$pan_image.removeClass('constrain')
    console.log('Legwork.Slides.PanningSlide :: activate')

  ###
  *------------------------------------------*
  | deactivate:void (-)
  |
  | Deactivate old slide
  *----------------------------------------###
  deactivate: ->
    console.log('Legwork.Slides.PanningSlide :: deactivate')

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

    @initPanning()

  ###
  *------------------------------------------*
  | 
  | Private Methods
  |
  *----------------------------------------###
  initPanning: =>
    @$pan_image
      .css
        'top': @vert_center + 'px'
        'left':  @horz_center + 'px'
      .on 'mousedown', (e) =>
        $t = $(e.currentTarget)
        
        $t.removeClass('constrain').data('pan', 
          'iMouseX': e.pageX
          'iMouseY': e.pageY
          'iPosX': $t.position().left
          'iPosY': $t.position().top
        ).on('mousemove', @_clickedDrag)
        
        Legwork.$doc.one('mouseup', @_constrainDrag)
        e.preventDefault()

  _clickedDrag: (e) =>
    data = $(e.currentTarget).data('pan')
    deltaX = e.pageX - data.iMouseX
    deltaY = e.pageY - data.iMouseY
    normalX = deltaX + data.iPosX
    normalY = deltaY + data.iPosY

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

    @$pan_image.unbind('mousemove', @_clickedDrag).addClass('constrain')

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