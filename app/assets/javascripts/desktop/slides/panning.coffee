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
    
    # Class vars
    # @$bounds = @$el
    # @$pan_image = $('img', @$el)

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
    @$bounds = Legwork.$wn
    @$pan_image = $('.pan-image', @$el)
    
    @$pan_image
      .css
        'top': -((@$pan_image.height() - @$bounds.height()) / 2) + 'px'
        'left': -((@$pan_image.width() - @$bounds.width()) / 2) + 'px'
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

  ###
  *------------------------------------------*
  | 
  | Private Methods
  |
  *----------------------------------------###
  _clickedDrag: (e) =>
    data = $(e.currentTarget).data('pan')
    deltaX = e.pageX - data.iMouseX
    deltaY = e.pageY - data.iMouseY
    normalX = deltaX + data.iPosX
    normalY = deltaY + data.iPosY

    @$pan_image.css(
      'top': normalY + 'px'
      'left': normalX + 'px'
    )

  _constrainDrag: () =>
    pX = @$pan_image.position().left
    pY = @$pan_image.position().top
    bX = @$bounds.width() - @$pan_image.width()
    bY = @$bounds.height() - @$pan_image.height()
    x = pX
    y = pY

    @$pan_image.unbind('mousemove', @_clickedDrag).addClass('constrain')

    if pX > 0 then x = 0
    if pY > 0 then y = 0
    if pX < bX then x = bX
    if pY < bY then y = bY

    @$pan_image.css(
      'top': y + 'px'
      'left': x + 'px'
    )