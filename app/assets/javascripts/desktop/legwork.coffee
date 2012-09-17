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

    Legwork.sequence_collections = {}

    # Class vars
    @$menu_btn = $('#menu-btn')
    @$bg_wrap = $('#wrap-the-background')
    @$canvas_wrap = $('#wrap-the-canvas')
    @$lines = $('#lines')
    @$line_wrap = $('#wrap-the-lines')
    @$stuff_wrap = $('#wrap-the-stuff')
    @$stuff_reveal = $('#reveal-the-stuff')
    @$detail = $('#detail')

    @History = window.History
    @stuff = []
    @lifelines = @getLifelines()
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
    @preloader = new Legwork.MainLoader({'$el': Legwork.$body, 'assets': Legwork.home.assets})

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
    obj = {
      'twitter': {
        'color': 'rgba(247, 142, 198, 1)',
        'coords': []
      },
      'work': {
        'color': 'rgba(234, 233, 56, 1)',
        'coords': []
      },
      'world': {
        'color': 'rgba(151, 213, 242, 1)',
        'coords': []
      }
    }

    for stuff, id in Legwork.home.layout
      category = @getStuffType(stuff.type).replace(/animated|sequenced/g, '')
      
      if category isnt ''
        obj[category].coords.push({'x':stuff.position[1], 'y':stuff.position[0]})

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
  lines: (obj, width, tightness) ->
    p = 0
    points = obj.coords

    @line_ctx.strokeStyle = obj.color
    @line_ctx.lineWidth = width

    @line_ctx.beginPath()
    @line_ctx.moveTo(@getOffset(points[0].x), @getOffset(points[0].y))

    for p in [1..(points.length - 1)]

      # For the second point set the it's control points
      if p is 1
        points[p].c1x = @getOffset(points[p - 1].x)
        points[p].c1y = @getOffset(points[p - 1].y)

      # For the penultimate point set the it's control points
      if p is (points.length - 1)
        points[p].c2x = @getOffset(points[p].x)
        points[p].c2y = @getOffset(points[p].y)
      else

        # Thanks to JORIKI and Pumbaa80 at stackexchange for all the help with this next bit!

        # Set some aliases for the previous, current and next points
        a = [@getOffset(points[p - 1].x), @getOffset(points[p - 1].y)]
        b = [@getOffset(points[p].x), @getOffset(points[p].y)]
        c = [@getOffset(points[p + 1].x), @getOffset(points[p + 1].y)]

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
      @line_ctx.bezierCurveTo(points[p].c1x, points[p].c1y, points[p].c2x, points[p].c2y, @getOffset(points[p].x), @getOffset(points[p].y))

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
      @lines(value, 1, 3)

  ###
  *------------------------------------------*
  | getOffset:void (-)
  |
  | v:number - value as % of width
  |
  | Get the offset of the passed val for
  | the current app size.
  *----------------------------------------###
  getOffset: (v) ->
    return (Math.floor(v * Legwork.app_width) + 1)

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
      $parent = if category is 'sequenced' or category is 'animated' then @$bg_wrap else @$stuff_wrap

      # Content
      switch category
        when 'sequenced'
          $content = $(JST['desktop/templates/sequence'](stuff))
          $('#' + stuff.content[0]).addClass('video-in').appendTo($content)
          $('#' + stuff.content[1]).addClass('video-out').appendTo($content)
        when 'animated'
          $content = $(JST['desktop/templates/animation'](stuff))
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
      $container.append($content).appendTo($parent)

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
    return t.replace(/\s|big|small|left|right|stuff|ignore/g, '')

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
        $t.not('.ignore').trigger('Legwork.deactivate')

  ###
  *------------------------------------------*
  | getNextTweet:object (-)
  |
  | Get the next Tweet.
  *----------------------------------------###
  getNextTweet: ->
    tweet = Legwork.twitter[@twitter_index]
    text = tweet.text
    timestamp = tweet.created_at
    date = ''
    source = tweet.source

    # test
    #text = 'This rad tweet is custom built for testing a #hashtag and a @mention of someone and is exactly 140 characters long. <a href="legworkstudio.com" target="_new">http://legworkstudio.com</a>'

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
      'date': date,
      'source': source
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
    for $t, index in @stuff
      pos = @getLayoutOffset($t.data('position'), Legwork.app_width)
      $t.css(pos)

      if (+pos.top.replace(/px/, '')) < Legwork.$wn.height()
        $t.addClass('ignore')
      else
        $t.removeClass('ignore')

  ###
  *------------------------------------------*
  | finishLayout:void (-)
  |
  | Finish layout.
  *----------------------------------------###
  finishLayout: ->
    @$lines
      .attr('width', Legwork.app_width)
      .attr('height', Math.floor(Legwork.$wn.height() / 2))

    @$canvas_wrap.show()

    Legwork.$wn.trigger('scroll')

  ###
  *------------------------------------------*
  | getLayoutOffset:object (-)
  |
  | p:array - [top, left]
  | w:number - current container width
  |
  | Get the position for the passed coords.
  *----------------------------------------###
  getLayoutOffset: (p, w) ->
    return {'top': Math.floor(w * p[0]) + 'px'}

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

    Legwork.event_horizon = Math.floor(Legwork.$wn.scrollTop() + (Legwork.$wn.height() / 2)) + 34

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
      @$canvas_wrap.stop(true, false).animate({'opacity':0.25}, 250, 'linear')

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
      $('.activate-it').css('display', '')

    if Legwork.app_width < 740
      $('.stuff').addClass('no-position')
    else
      $('.stuff').removeClass('no-position')
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
      $t.find('.activate-it').fadeIn(250)

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
      $t.find('.activate-it').fadeOut(250)

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
        $('#detail-close-btn').css('margin-top', '-55px')
        $('#related-drawer').css('margin-bottom', '-256px')
        @$detail.fadeOut 'fast', ->
          $('#detail-inner').removeClass('open')
      when 'work'
        if @$detail.is(':visible')
          @openWork(to[1])
        else
          @openDetail(@openWork, to[1])
      when 'world'
        if @$detail.is(':visible')
          @openWorld(to[1])
        else
          @openDetail(@openWorld, to[1])
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
  openDetail: (callback, item) ->
    detail_in = new Legwork.ImageSequence({
      '$el': @$detail,
      'imgs': Legwork.sequence_collections['detail_open']
      'fps': 15
    })

    @$detail
      .css('background-color', 'transparent')
      .show()
      .off('Legwork.sequence_complete')
      .one 'Legwork.sequence_complete', (e) =>
        detail_in.destroy()
        $(e.currentTarget).css('background-color', '#000')

        setTimeout ->
          callback(item)
        , 500

        setTimeout =>
          $('#detail-close-btn').animate
            'margin-top': '0px'
          ,
            'duration': 500
            'easing': 'easeInOutExpo'
            'step': (now, fx) ->
              $('#related-drawer').css('margin-bottom', -201 + now + 'px')
        , 1000

  ###
  *------------------------------------------*
  | openWork:void (-)
  | 
  | work:string - work id
  | 
  | Open a work detail.
  *----------------------------------------###
  openWork: (work) ->
    $d = $('#detail-inner')

    console.log($d.hasClass('open'))

    if $d.hasClass('open')
      $d.removeClass('open')
      setTimeout ->
        $d.addClass('open')
      , 1000
    else
      $d.addClass('open')


  ###
  *------------------------------------------*
  | openWorld:void (-)
  | 
  | world:string - world id
  | 
  | Open a world detail.
  *----------------------------------------###
  openWorld: (world) ->
    $d = $('#detail-inner')

    if $d.hasClass('open')
      $d.removeClass('open')
      setTimeout ->
        $d.addClass('open')
      , 1000
    else
      $d.addClass('open')

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