###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is still hot.

###

#= require ./slide

class Legwork.Slides.Slideshow extends Legwork.Slides.Slide

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
    @$el = $(JST["desktop/templates/slides/slideshow"](@model))

    @$slideshow = $('.slideshow', @$el)
    @$ss = $('.ss-slide', @$el)
    @$vs = $('.vimeo-slide', @$el)
    @$vp = $('.vimeo-poster', @$el)
    @$vi = $('.vimeo-iframe', @$el)

    @$progress = $('.progress', @$el)
    @$track = $('.progress-track', @$el)
    @$bar = $('.progress-bar', @$el)
    @total_slides = @$ss.length
    @panels = 100 / @total_slides

    return @$el

  ###
  *------------------------------------------*
  | initialize:void (-)
  |
  | See Legwork.Slides.Slide initilaize
  *----------------------------------------###
  initialize: ->
    @_buildProgressPanels()
    @_fetchVimeoThumbnails()

    @SLIDE_DURATION = 6666
    @DELAY = 33
    @slide_time = 0
    @total_time = @SLIDE_DURATION * @total_slides
    @slide_interval
    @vimeoPlaying
    
    @$vs.on Legwork.click, @_playVimeo

  ###
  *------------------------------------------*
  | activate:void (-)
  |
  | Activate new/current slide
  *----------------------------------------###
  activate: ->
    @_resetSlideshow()
    @vimeoPlaying = false

    unless Modernizr.touch
      @_startSlideshow()
      @$slideshow.on
        'mouseenter': =>
          if @vimeoPlaying is false then @_stopSlideshow()
        'mouseleave': =>
          if @vimeoPlaying is false then @_startSlideshow()

      @$progress.on
        'mouseenter': =>
          if @vimeoPlaying is false then @_stopSlideshow()
        'mouseleave': =>
          if @vimeoPlaying is false then @_startSlideshow()

    @$progress.on Legwork.click, '.panel', @_nextSlide

  ###
  *------------------------------------------*
  | deactivate:void (-)
  |
  | Deactivate old slide
  *----------------------------------------###
  deactivate: ->
    @_removeVimeo()
    @_stopSlideshow()

    unless Modernizr.touch then @$slideshow.off 'mouseenter mouseleave'

  ###
  *------------------------------------------*
  |
  | Private Methods
  |
  *----------------------------------------###
  _buildProgressPanels: =>
    n = 0
    panel = '<div class="panel"></div>'
    tick = '<span></span>'
    bg_color = @model.background_color

    while n < @total_slides
      distance = @panels * n
      @$track.append panel
      $('.panel', @$track)
        .eq(n).css
          'width': @panels + '%'
          'left': distance + '%'
        .append(tick)
      $('.panel span', @$track).css('background-color', bg_color)
      n++

    @$panel = $('.panel', @$progress)

  _fetchVimeoThumbnails: =>
    @$vs.each ->
      $t = $(this)
      $p = $('.vimeo-poster', $t)
      id = $t.data('vimeo')

      $.getJSON "http://www.vimeo.com/api/v2/video/#{id}.json?callback=?", {format: "json"}, (data) =>
        $p.append("<img src='#{data[0].thumbnail_large}' alt='' /><div class='vimeo-play-btn'></div>")

  _resetSlideshow: =>
    clearInterval(@slide_interval)
    @slide_time = 0

    @$ss.removeClass('active').css 'left', '100%'
    @$ss.first().addClass('active').css 'left', '0%'

    @$panel.removeClass('selected')
    @$panel.first().addClass('selected')

    @_removeVimeo()

  _startSlideshow: =>
    clearInterval(@slide_interval)

    @slide_interval = setInterval =>
      @slide_time = if @slide_time >= @total_time then 0 else @slide_time + @DELAY
      @_slideProgress()
    , @DELAY

  _stopSlideshow: =>
    clearInterval(@slide_interval)

  _slideProgress: =>
    perc = if @slide_time is 0 then 0 else 100 / (@total_time / @slide_time)
    selected = Math.floor (perc / 100) * 4
    $selected = @$panel.eq(selected)

    if $selected.hasClass('selected') is false
      $selected.trigger Legwork.click

    @$bar.css 'width', perc + '%'

  _jumpTo: (index) =>
    @slide_time = @SLIDE_DURATION * index
    @_slideProgress()

  _nextSlide: (e) =>
    $target = $(e.currentTarget)
    index = $target.index() - 1

    if $target.hasClass('selected') is false
      @$progress.off Legwork.click, '.panel', @_nextSlide

      $active = $('.active', @$slideshow)
      $next_slide = @$ss.eq(index)

      @$ss.css('left', '100%')
      $active.css({'left':'0%', 'z-index':'1'}).removeClass('active')
      $next_slide.css('z-index','2').addClass('active').animate
        left: '0%'
      , 666, 'easeInOutExpo', =>
        @_removeVimeo()
        @$ss.not($next_slide).css('left', '100%')
        @$progress.on Legwork.click, '.panel', @_nextSlide

    @$panel.removeClass('selected')
    $target.addClass('selected')

    @_jumpTo(index)

  _playVimeo: (e) =>
    @vimeoPlaying = true

    $t = $(e.currentTarget)
    $p = $('.vimeo-poster', $t)
    $v = $('.vimeo-iframe', $t)
    id = $t.data('vimeo')

    $v.empty().append "<iframe src='http://player.vimeo.com/video/#{id}?title=0&amp;byline=0&amp;portrait=0&amp;badge=0&amp;color=ffffff&amp;autoplay=1' width='730' height='411' frameborder='0' webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>"

    $p.delay(333).fadeOut(666)

  _removeVimeo: =>
    @vimeoPlaying = false
    @$vi.empty()
    @$vp.show()
