###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is hot.

###

class Legwork.Application

  ###
  *------------------------------------------*
  | constructor:void (-)
  |
  | Construct the fuggin' thing.
  *----------------------------------------###
  constructor: ->
    # Global vars
    Legwork.$wn = $(window)
    Legwork.$doc = $(document)
    Legwork.$html = $('html')
    Legwork.$body = $('body')
    Legwork.$wrapper = $('#wrapper')
    Legwork.$header = $('header')
    Legwork.$view = $('#legwork')
    Legwork.$footer = $('footer')

    Legwork.sequences = {}
    Legwork.slide_controllers = {}
    Legwork.current_detail_controller = null

    Legwork.click = 'click'
    Legwork.mousedown = 'mousedown'
    Legwork.mouseup = 'mouseup'
    Legwork.mousemove = 'mousemove'

    if Modernizr.touch then Legwork.click = 'touchstart'
    if Modernizr.touch then Legwork.mousedown = 'touchstart'
    if Modernizr.touch then Legwork.mouseup = 'touchend'
    if Modernizr.touch then Legwork.mousemove = 'touchmove'

    # Class vars
    @$menu_btn = $('#menu-btn')
    @$canvas_wrap = $('#wrap-the-canvas')
    @$lines = $('#lines')
    @$stuff_wrap = $('#wrap-the-stuff')
    @$stuff_reveal = $('#reveal-the-stuff')
    @$detail = $('#detail')
    @$detail_inner = $('#detail-inner')
    @$detail_close = $('#detail-close-btn')

    @History = window.History
    @stuff = []
    @lifelines = []
    @line_ctx = @$lines[0].getContext('2d')
    @twitter_index = 0
    @scroll_timeout = 0
    @resize_timeout = 0
    @vector_utils = new Legwork.VectorUtils()

    @preload()

  ###
  *------------------------------------------*
  | preload:void (-)
  |
  | Merge assets and preload.
  *----------------------------------------###
  preload: ->
    # Merge initial assets
    # TODO: All or some?
    home_assets = Legwork.home.assets
    site_assets = {images:[], videos:[], sequences:[]}
    main_assets = {images:[], videos:[], sequences:[]}

    for id, work of Legwork.work
      site_assets.images = _.union(site_assets.images, work.assets.images)
      site_assets.videos = _.union(site_assets.videos, work.assets.videos)
      site_assets.sequences = _.union(site_assets.sequences, work.assets.sequences)

    for id, world of Legwork.world
      site_assets.images = _.union(site_assets.images, world.assets.images)
      site_assets.videos = _.union(site_assets.videos, world.assets.videos)
      site_assets.sequences = _.union(site_assets.sequences, world.assets.sequences)

    main_assets.images = _.union(home_assets.images, site_assets.images)
    main_assets.videos = _.union(home_assets.videos, site_assets.videos)
    main_assets.sequences = _.union(home_assets.sequences, site_assets.sequences)

    @preloader = new Legwork.MainLoader({'$el': Legwork.$body, 'assets': main_assets})

    Legwork.$body
      .off('Legwork.loaded', @onLoadComplete)
      .one('Legwork.loaded', @onLoadComplete)

  ###
  *------------------------------------------*
  | onLoadComplete:void (=)
  |
  | e:object - event object
  |
  | Loading complete, finish transition.
  *----------------------------------------###
  onLoadComplete: (e) =>
    @build()

    @$sequence = $('.sequenced')
    @lifelines = @getLifelines()

    @$stuff_reveal.delay(111).animate
      'width':'0%'
    , 666, 'easeInOutExpo', =>
      @$stuff_reveal.remove()

      Legwork.$header.find('h1')
        .animate
          'margin-bottom':'0px'
        , 666, 'easeInOutExpo'

  ###
  *------------------------------------------*
  | getLifelines:object (-)
  |
  | Build the lifelines object.
  *----------------------------------------###
  getLifelines: ->
    levels = 8
    side = 'l'
    colors = [
      #'rgba(234, 233, 56, 0.0375)',
      'rgba(151, 213, 242, 0.0375)'
    ]
    obj = []

    for item, i in colors
      for j in [0..(levels - 1)]
        line = {
          'color': colors[i],
          'coords': [],
          'tightness': (Math.random() * 1 + (i * 0.5)) + 2,
          'weight': (Math.random() * 50) + (j * 20)
        }

        obj.push(line)

    @$sequence.each (index, elm)->
      for item, i in obj
        if i % levels is 0
          xpos = (Math.random() * (Legwork.$wn.width() * 0.4))
          ypos = $(elm).offset().top + (Math.random() * 300)

          if side is 'r'
            xpos = Legwork.$wn.width() - xpos

        item.coords.push({'x':xpos, 'y':ypos})

      side = if side is 'r' then 'l' else 'r'

    return obj

  ###
  *------------------------------------------*
  | clear:void (-)
  |
  | cnv:dom - canvas
  |
  | Clear the canvas.
  *----------------------------------------###
  clear: (cnv) ->
    ctx = cnv.getContext('2d')
    ctx.clearRect(0, 0, cnv.width, cnv.height)
    cnv.width = cnv.width

  ###
  *------------------------------------------*
  | lines:void (-)
  |
  | obj:object - ref to lifelines item
  | width:number - stroke size
  | tightness:number - how curvatious?
  |
  | Draw lines.
  | Couldn't have done this without
  | http://bit.ly/tvuzR4. Thanks CBH!
  *----------------------------------------###
  lines: (obj) ->
    p = 0
    points = obj.coords
    tightness = obj.tightness

    @line_ctx.strokeStyle = obj.color
    @line_ctx.lineWidth = obj.weight + Math.round(Math.random() * 20)

    @line_ctx.beginPath()
    @line_ctx.moveTo(points[0].x, points[0].y)

    for p in [1..(points.length - 1)]

      # For the second point set the it's control points
      if p is 1
        points[p].c1x = points[p - 1].x
        points[p].c1y = points[p - 1].y

      # For the penultimate point set the it's control points
      if p is (points.length - 1)
        points[p].c2x = points[p].x
        points[p].c2y = points[p].y
      else

        # Thanks to JORIKI and Pumbaa80 at stackexchange for all the help with this next bit!

        # Set some aliases for the previous, current and next points
        a = [points[p - 1].x, points[p - 1].y]
        b = [points[p].x, points[p].y]
        c = [points[p + 1].x, points[p + 1].y]

        # Get the change in the vectors
        delta_a = @vector_utils.subtract(b, a)
        delta_c = @vector_utils.subtract(c, b)

        # Get vector (m) perpendicular bisector
        m = @vector_utils.normalize(@vector_utils.add(@vector_utils.normalize(delta_a), @vector_utils.normalize(delta_c)))

        # Get ma and mc
        ma = [-m[0], -m[1]]
        mc = m

        # Get the control point coordinates
        points[p].c2x = b[0] + ((Math.sqrt(@vector_utils.sqr(delta_a[0]) + @vector_utils.sqr(delta_a[1])) / tightness) * ma[0])
        points[p].c2y = b[1] + ((Math.sqrt(@vector_utils.sqr(delta_a[0]) + @vector_utils.sqr(delta_a[1])) / tightness) * ma[1])
        points[p + 1].c1x = b[0] + ((Math.sqrt(@vector_utils.sqr(delta_c[0]) + @vector_utils.sqr(delta_c[1])) / tightness) * mc[0])
        points[p + 1].c1y = b[1] + ((Math.sqrt(@vector_utils.sqr(delta_c[0]) + @vector_utils.sqr(delta_c[1])) / tightness) * mc[1])

      # lines
      @line_ctx.bezierCurveTo(points[p].c1x, points[p].c1y, points[p].c2x, points[p].c2y, points[p].x, points[p].y)

    @line_ctx.stroke()

  ###
  *------------------------------------------*
  | doLines:void (-)
  |
  | v:number - value as % of width
  |
  | Where's the fuggin' mirror?
  *----------------------------------------###
  doLines: ->
    @clear(@$lines[0])
    @line_ctx.translate(0, -Legwork.$wn.scrollTop())

    for key, value of @lifelines
      @lines(value)

  ###
  *------------------------------------------*
  | build:void (-)
  |
  | DOM manipulations, instantiations, etc.
  *----------------------------------------###
  build: ->
    # Build the mobile menu if the button is visible
    if @$menu_btn.is(':visible') is true
      @mobile_menu = new Legwork.MobileMenu()

    # Add the stuff
    for stuff, id in Legwork.home.layout
      category = @getStuffType(stuff.type)

      # Container
      $container = $(JST['desktop/templates/stuff'](stuff))
      $content = ''

      # Content
      switch category
        when 'sequenced'
          $content = $(JST['desktop/templates/sequence'](stuff))

          $vid_wrap = $content.find('.sequenced-content-wrap')

          $('#' + stuff.content[0]).addClass('video-in').appendTo($vid_wrap)
          $('#' + stuff.content[1]).addClass('video-out').appendTo($vid_wrap)
        when 'twitter'
          $content = $(JST['desktop/templates/twitter'](@getNextTweet()))
        when 'work'
          data = Legwork.work[stuff.content]
          data.link = '/work/' + stuff.content
          $content = $(JST['desktop/templates/work'](data))
        when 'world'
          data = Legwork.world[stuff.content]
          data.link = '/world/' + stuff.content
          $content = $(JST['desktop/templates/world'](data))

      # Append to DOM
      $container.append($content).appendTo(@$stuff_wrap)

      # Initial Event
      $container
        .one('Legwork.activate', @onStuffActivate)

      # Collect
      @stuff.push($container)

    @observeSomeSweetEvents()

  ###
  *------------------------------------------*
  | getStuffType:void (-)
  |
  | t:string - type/class string
  |
  | What type of stuff are we dealing with?
  *----------------------------------------###
  getStuffType: (t) ->
    return t.replace(/\s|cf|left|right|stuff/g, '')

  ###
  *------------------------------------------*
  | doStuff:void (-)
  |
  | Activate/Deactivate stuff based on
  | on scroll position.
  *----------------------------------------###
  doStuff: ->
    for $t, index in @stuff
      if $t.offset().top < Legwork.event_horizon
        $t.trigger('Legwork.activate')
      else
        $t.trigger('Legwork.deactivate')

  ###
  *------------------------------------------*
  | getNextTweet:object (-)
  |
  | Get the next Tweet.
  *----------------------------------------###
  getNextTweet: ->
    tweet = '0' #Legwork.twitter[@twitter_index]
    text = '' #tweet.text
    timestamp = 0 #tweet.created_at
    date = ''
    source = '' #tweet.source

    # test
    text = 'This rad tweet is custom built for testing a #hashtag and a @mention of someone and is exactly 140 characters long. <a href="legworkstudio.com" target="_new">http://legworkstudio.com</a>'

    @twitter_index++

    # format mentions, hashes and links
    text = text.replace(/(^|\s)(@\w+)\b/g, ' <span class="tweet-at">$2</span>')
    text = text.replace(/(^|\s)(#\w+)\b/g, ' <span class="tweet-hash">$2</span>')
    text = text.replace(/([A-Za-z]+:\/\/[A-Za-z0-9-_]+\.[A-Za-z0-9-_:%&~\?\/.=]+)/g, '<a href="$1" target="_new">$1</a>')

    # format date
    time_since_tweet = Math.floor((new Date() - new Date(Date.parse(timestamp))) / 1000)

    if time_since_tweet <= 1
      date = "Just now"
    else if time_since_tweet < 20
      date = @toWords(time_since_tweet) + " seconds ago"
    else if time_since_tweet < 40
      date = "Half a minute ago"
    else if time_since_tweet < 60
      date = "Less than a minute ago"
    else if time_since_tweet <= 90
      date = "One minute ago"
    else if time_since_tweet <= 3540
      date = @toWords(Math.round(time_since_tweet / 60)) + " minutes ago"
    else if time_since_tweet <= 5400
      date = "One hour ago"
    else if time_since_tweet <= 86400
      date = @toWords(Math.round(time_since_tweet / 3600)) + " hours ago"
    else if time_since_tweet <= 129600
      date = "One day ago"
    else if time_since_tweet < 604800
      date = @toWords(Math.round(time_since_tweet / 86400)) + " days ago"
    else if time_since_tweet <= 777600
      date = "One week ago"
    else if time_since_tweet <= 1000000
      date = "In ancient times"

    # prepare source
    source = source.replace(/(^<.+>)(.+)(<.+>$)/, '$2')
    source = source.replace(/web/, 'twitter.com')

    return {
      'text': text,
      'details': '10 years ago via a fax machine' #date + source
    }

  ###
  *------------------------------------------*
  | toWords:string (-)
  |
  | s:number - number to convert
  |
  | Turn a number into some sweet words.
  *----------------------------------------###
  toWords: (s) ->
    th = ['', ' thousand', ' million', ' billion', ' trillion', ' quadrillion', ' quintillion']
    dg = ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine']
    tn = ['ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen']
    tw = ['twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety']

    s = s.toString()
    s = s.replace(/[\, ]/g, '')
    x = s.length
    n = s.split('')
    str = ''
    sk = 0

    for i in [0..(x - 1)]
      if (x - i) % 3 is 2
        if n[i] is '1'
          str += tn[Number(n[i + 1])] + ' '
          i++ # TODO: isn't working
          sk = 1
        else if n[i] isnt 0
          str += tw[n[i] - 2] + ' '
          sk = 1
      else if n[i] isnt 0
        str += dg[n[i]] + ' '
        if (x - i) % 3 is 0
          str += 'hundred '
        sk = 1
      if (x - i) % 3 is 1
        if sk is 1
          str += th[(x - i - 1) / 3] + ' '
        sk = 0

    return str.replace(/\s+/g, ' ')

  ###
  *------------------------------------------*
  | startLayout:void (-)
  |
  | Start layout.
  *----------------------------------------###
  startLayout: ->
    @$canvas_wrap.hide()

  ###
  *------------------------------------------*
  | layout:void (-)
  |
  | Compute layout for current window width.
  *----------------------------------------###
  layout: ->

  ###
  *------------------------------------------*
  | finishLayout:void (-)
  |
  | Finish layout.
  *----------------------------------------###
  finishLayout: ->
    @$lines
      .attr('width', Legwork.app_width)
      .attr('height', Math.floor(Legwork.$wn.height() * 0.56))

    @lifelines = @getLifelines()
    @$canvas_wrap.show()

    Legwork.$wn.trigger('scroll')

  ###
  *------------------------------------------*
  | observeSomeSweetEvents:void (-)
  |
  | Observe events scoped to this class.
  *----------------------------------------###
  observeSomeSweetEvents: ->
    # History
    @History.Adapter.bind(window, 'statechange', @onAppStateChange)

    # Window
    Legwork.$wn
      .one('resize', @onResizeStart)
      .on('resize', @onResize)
      .one('scroll', @onScrollStart)
      .on('scroll', @onScroll)
      .trigger('resize')
      .trigger('scroll')

    # Ajaxy
    Legwork.$body
      .on('click', '.ajaxy', @onAjaxyLinkClick)

  ###
  *------------------------------------------*
  | onScrollStart:void (=)
  | 
  | e:object - event object
  | 
  | Window has started scrolling.
  *----------------------------------------###
  onScrollStart: (e) =>
    if Legwork.app_width >= 1025
      @$canvas_wrap.stop(true, false).css('opacity', 1)

  ###
  *------------------------------------------*
  | onScroll:void (=)
  | 
  | e:object - event object
  | 
  | Window is being scrolled.
  *----------------------------------------###
  onScroll: (e) =>
    # Debounce for onScrollComplete
    clearTimeout(@scroll_timeout)
    @scroll_timeout = setTimeout(@onScrollComplete, 333)

    Legwork.event_horizon = Math.floor(Legwork.$wn.scrollTop() + (Legwork.$wn.height() * 0.56)) + 54

    if Legwork.app_width >= 1025
      @doLines()
      @doStuff()

  ###
  *------------------------------------------*
  | onScrollComplete:void (=)
  | 
  | Window is done being scrolled.
  *----------------------------------------###
  onScrollComplete: =>
    # Re-add event for onScrollStart
    Legwork.$wn
      .one('scroll', @onScrollStart)

    if Legwork.app_width >= 1025
      @$canvas_wrap.stop(true, false).animate({'opacity':0.666}, 250, 'linear')

  ###
  *------------------------------------------*
  | onResizeStart:void (=)
  | 
  | Resize has started.
  *----------------------------------------###
  onResizeStart: (e) =>
    if Legwork.app_width >= 740
      @startLayout()

  ###
  *------------------------------------------*
  | onResize:void (=)
  | 
  | e:object - event object
  | 
  | Window is being resized.
  *----------------------------------------###
  onResize: (e) =>
    # Debounce for onResizeComplete
    clearTimeout(@resize_timeout)
    @resize_timeout = setTimeout(@onResizeComplete, 333)

    # Global cache app size
    Legwork.app_width = @$stuff_wrap.outerWidth()

    # Reset the mobile header if it exists, otherwise build
    # the mobile menu if the button becomese visible
    if @mobile_menu?
      @mobile_menu.resetHeader()
    else if @$menu_btn.is(':visible') is true
      @mobile_menu = new Legwork.MobileMenu()

    if Legwork.app_width < 1025
      $('.sequenced-inner').find('video').hide()

    if Legwork.app_width < 740
      @layout()

  ###
  *------------------------------------------*
  | onResizeComplete:void (=)
  | 
  | Resize is finished.
  *----------------------------------------###
  onResizeComplete: =>
    # Re-add event for onResizeStart
    Legwork.$wn
      .one('resize', @onResizeStart)

    if Legwork.app_width >= 740
      @finishLayout()

    if Legwork.app_width >= 1025
      for $t, index in @stuff
        $t
          .off('Legwork.activate')
          .off('Legwork.deactivate')
          .one('Legwork.activate', @onStuffActivate)

      Legwork.$wn.trigger('scroll')

  ###
  *------------------------------------------*
  | onStuffActivate:void (=)
  | 
  | e:object - event object
  | 
  | This stuff got activated.
  *----------------------------------------###
  onStuffActivate: (e) =>
    $t = $(e.currentTarget)
    category = @getStuffType($t.attr('class'))

    if category is 'sequenced'
      @playSequence($t, 'in')
    else
      #$t.find('.activate-it').fadeIn(250)

    $t.one('Legwork.deactivate', @onStuffDeactivate)

  ###
  *------------------------------------------*
  | onStuffDeactivate:void (=)
  | 
  | e:object - event object
  | 
  | This stuff got deactivated.
  *----------------------------------------###
  onStuffDeactivate: (e) =>
    $t = $(e.currentTarget)
    category = @getStuffType($t.attr('class'))

    if category is 'sequenced'
      @playSequence($t, 'out')
    else
      #$t.find('.activate-it').fadeOut(250)

    $t.one('Legwork.activate', @onStuffActivate)

  ###
  *------------------------------------------*
  | playSequence:void (-)
  | 
  | $parent:dom - sequence container
  | type:string - in or out
  | 
  | Play a sequence video.
  *----------------------------------------###
  playSequence: ($parent, type) ->
    $vid = $parent.find('.video-' + type)

    $vid[0].currentTime = 0

    setTimeout ->
      $parent.find('video').hide()
      $vid.show()
      $vid[0].play()
    , 50

  ###
  *------------------------------------------*
  | onAjaxyLinkClick:void (=)
  | 
  | e:object - event object
  | 
  | User has clicked an ajaxy link.
  *----------------------------------------###
  onAjaxyLinkClick: (e) =>
    e.preventDefault()

    if e.which is 2 or e.metaKey is true then return true

    $t = $(e.currentTarget)

    if $t.hasClass('selected') is true
      $t.removeClass('selected')
      @History.pushState(null, null, '/')
    else
      $('.ajaxy').removeClass('selected')
      $t.addClass('selected')
      @History.pushState(null, null, $t.attr('href'))

  ###
  *------------------------------------------*
  | onAppStateChange:void (=)
  | 
  | App state (URL) has changed.
  *----------------------------------------###
  onAppStateChange: =>
    @state = @History.getState()

    url = @state.hash.replace(/^\/|\.|\#/g, '')
    parts = url.split('/')

    @route(parts)

  ###
  *------------------------------------------*
  | route:void (-)
  | 
  | to:array - url parts
  | 
  | Route to the passed url.
  *----------------------------------------###
  route: (to) ->
    switch to[0]
      when ''
        @resetDetail()
      when 'work', 'world'
        if @$detail.is(':visible')
          @loadDetail(to)
        else
          @openDetail(to)
      when 'filter'
        @openFilter(to[1])

  ###
  *------------------------------------------*
  | openDetail:void (-)
  | 
  | callback:function - callback
  | item:string - work/world id
  | 
  | Open the detail view.
  *----------------------------------------###
  openDetail: (item) ->
    detail_in = new Legwork.ImageSequence({
      '$el': @$detail,
      'settings': Legwork.sequences['detail_open']
    })

    @$detail
      .css('background-color', 'transparent')
      .show()
      .off('Legwork.sequence_complete')
      .one 'Legwork.sequence_complete', (e) =>
        detail_in.destroy()
        @$detail.css('background-color', '#000')

        setTimeout =>
          @loadDetail(item)
        , 500

        setTimeout =>
          @$detail_close.animate
            'margin-top': '0px'
          ,
            'duration': 500
            'easing': 'easeInOutExpo'
        , 1000

  ###
  *------------------------------------------*
  | openWork:void (-)
  | 
  | item:array - type, id
  | 
  | Load a detail item.
  *----------------------------------------###
  loadDetail: (item) ->
    model = Legwork[item[0]][item[1]]

    if Legwork.slide_controllers[item[1]]?
      controller = Legwork.slide_controllers[item[1]]
    else
      if model.slides.length > 1
        controller = Legwork.slide_controllers[item[1]] = new Legwork.CaseStudyDetail
          model: model
          zone: item[0]
          slug: item[1]
      else
        controller = Legwork.slide_controllers[item[1]] = new Legwork.SingleDetail
          model: model
          zone: item[0]
          slug: item[1]

      @$detail_inner.append controller.build()
      controller.initialize()

    controller.activate()
    Legwork.current_detail_controller = controller

  ###
  *------------------------------------------*
  | resetDetail:void (-)
  | 
  | Reset the detail view.
  *----------------------------------------###
  resetDetail: () ->
    @$detail_close.css('margin-top', '-55px')
    @$detail.fadeOut 'fast', =>
      Legwork.current_detail_controller.deactivate()

  ###
  *------------------------------------------*
  | openFilter:void (-)
  | 
  | filter:string - filter id
  | 
  | Open a filter.
  *----------------------------------------###
  openFilter: (filter) ->
    console.log('add 5 canvases and roll, son!')

# Kick the tires and light the fires!
$ ->
  window.application = new Legwork.Application