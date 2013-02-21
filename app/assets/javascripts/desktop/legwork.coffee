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
    Legwork.$logo = $('h1', Legwork.$header)

    Legwork.filters = ['interactive', 'motion', 'illustration', 'about-us', 'open-source', 'extracurricular']

    Legwork.sequences = {}
    Legwork.slide_controllers = {}
    Legwork.open_detail_state = null
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
    @$filter_wrap = $('#wrap-the-filter')
    @$stuff_reveal = $('#reveal-the-stuff')
    @$detail = $('#detail')
    @$detail_inner = $('#detail-inner')
    @$detail_close = $('#detail-close-btn')
    @$related_btn = $('#related-btn')

    @History = window.History
    @sequenced_stuff = []
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
    home_assets = Legwork.Home.assets
    site_assets = {images:[], videos:[], sequences:[]}
    main_assets = {images:[], videos:[], sequences:[]}

    for id, work of Legwork.Work
      site_assets.images = _.union(site_assets.images, work.assets.images)
      site_assets.videos = _.union(site_assets.videos, work.assets.videos)
      site_assets.sequences = _.union(site_assets.sequences, work.assets.sequences)

    for id, world of Legwork.World
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

    @$launch = $('.launch-btn')
    @$sequence = $('.sequenced')
    @lifelines = @getLifelines()

    @observeSomeSweetEvents()

    # Check initial url and set state
    @state = @History.getState()
    url = @state.hash.replace(/^\/|\.|\#/g, '')

    if url is ''
      @current_state = ''
      @homeTransition()
    else if url in Legwork.filters
      @$canvas_wrap.hide()
      @$stuff_wrap.hide()
      @$filter_wrap.show()
      @buildFilter(url)

      # Set filter button
      Legwork.$header.find('a[id$="-' + url + '"]').addClass('selected')

      @current_state = 'filter'
      @homeTransition()
    else
      # TODO: try catch here and serve 404 if needed

      @$detail
        .show()
        .css('background-color', '#000')

      @$stuff_reveal
        .hide()
        .css({
          'position': 'fixed',
          'width': '100%'
        })

      Legwork.$header.css 'margin-top','0px'
      Legwork.$footer.css 'bottom','0px'
      Legwork.$logo.css 'margin-bottom','0px'

      Legwork.open_detail_state = url
      @loadDetail(url)
      @detailControlsIn()

      @current_state = 'detail'

  ###
  *------------------------------------------*
  | homeTransition:void (-)
  |
  | Transition the home or filter view in.
  *----------------------------------------###
  homeTransition: ->
    # TODO: drop menus in
    Legwork.$header.animate
      'margin-top': '0px'
    ,
      'duration': 500
      'easing': 'easeInOutExpo'
      'step': (now, fx) =>
        Legwork.$footer.css('bottom', now + 'px')
      'complete': =>
        Legwork.$logo.animate
          'margin-bottom':'0px'
        , 500, 'easeInOutExpo'

        reveal = new Legwork.ImageSequence({
          '$el': @$stuff_reveal,
          'settings': Legwork.sequences['reveal']
        })

        @$stuff_reveal
          .off('sequence_frame')
          .one 'sequence_frame', (e) =>
            setTimeout =>
              @$stuff_reveal.css('background-color', 'transparent')
            , 250
          .off('sequence_complete')
          .one 'sequence_complete', (e) =>
            @$stuff_reveal.hide()
            reveal.destroy()

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
      'rgba(234, 233, 56, 0.0375)',
      'rgba(151, 213, 242, 0.0375)',
      'rgba(247, 142, 198, 0.0375)',
      'rgba(179, 227, 148, 0.0375)'
    ]
    color = colors[Math.floor(Math.random() * colors.length)]
    obj = []

    for j in [0..(levels - 1)]
      line = {
        'color': color,
        'coords': [],
        'tightness': (Math.random() * 1) + 3,
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
  | Clear the canvas. Now you've done it.
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
    for stuff, id in Legwork.Home.layout
      category = @getStuffType(stuff.type)

      # Content
      switch category
        when 'sequenced'
          $content = $(JST['desktop/templates/sequence'](stuff))

          $vid_wrap = $content.find('.sequenced-content-wrap')

          $('#' + stuff.content[0]).addClass('video-in').appendTo($vid_wrap)
          $('#' + stuff.content[1]).addClass('video-out').appendTo($vid_wrap)

          # Collect
          @sequenced_stuff.push($content)
        when 'twitter'
          data = {
            tweets: [@getNextTweet(), @getNextTweet()]
          }
          data.type = category
          $content = $(JST['desktop/templates/twitter'](data))
        when 'work', 'world'
          data = Legwork.Work[stuff.content] or Legwork.World[stuff.content]
          data.type = category
          data.link = '/' + stuff.content
          $content = $(JST['desktop/templates/ww'](data))

      # Append to DOM
      # TODO: append all at once?
      $content.appendTo(@$stuff_wrap)

  ###
  *------------------------------------------*
  | getStuffType:string (-)
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
    for $t, index in @sequenced_stuff
      if $t.offset().top < Legwork.event_horizon
        $t.trigger('activate')
      else
        $t.trigger('deactivate')

  ###
  *------------------------------------------*
  | getNextTweet:object (-)
  |
  | Get the next Tweet. Go ahead, get 'er.
  *----------------------------------------###
  getNextTweet: ->
    tweet = Legwork.twitter[@twitter_index]
    text = tweet.text
    timestamp = tweet.created_at
    date = ''
    source = tweet.source

    # TODO: remove this test text once Twitter is caching and good to go
    # text = 'This rad tweet is custom built for testing a #hashtag and a @mention of someone and is exactly 140 characters long. <a href="legworkstudio.com" target="_new">http://legworkstudio.com</a>'

    @twitter_index++

    # format mentions, hashes and links
    text = text.replace(/([A-Za-z]+:\/\/[A-Za-z0-9-_]+\.[A-Za-z0-9-_:%&~\?\/.=]+)/g, '<a href="$1" target="_new">$1</a>')
    text = text.replace(/(^|\s)(@\w+)\b/g, (match, p1, p2, offset, string) ->
      return ' <a href="http://twitter.com/' + p2.replace(/@/, '') + '" target="_new">' + p2 + '</a>'
    )
    text = text.replace(/(^|\s)(#\w+)\b/g, (match, p1, p2, offset, string) ->
      return ' <a class="tweet-hash" href="http://twitter.com/search?q=' + p2.replace(/#/, '') + '" target="_new">' + p2 + '</a>'
    )

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
    else
      date = "In the ancient times"

    # prepare source
    source = source.replace(/(^<.+>)(.+)(<.+>$)/, '$2')
    source = source.replace(/web/, 'twitter.com')

    return {
      'text': text,
      'details': date.charAt(0).toUpperCase() + date.slice(1) + ' via ' + source
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
      .attr('height', Math.floor(Legwork.$wn.height() * 0.50))

    @lifelines = @getLifelines()

    if @current_state is ''
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

    # Ajaxy
    Legwork.$body
      .on('click', '.ajaxy', @onAjaxyLinkClick)

    # Launch
    Legwork.$body
      .on('mouseenter', '.launch-btn', @onStuffHover)
      .on('mouseleave', '.launch-btn', @onStuffHover)

    return false

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

    Legwork.event_horizon = Math.floor(Legwork.$wn.scrollTop() + (Legwork.$wn.height() * 0.50))

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
  | turnScroll:void (-)
  |
  | s:string - 'on' or 'off'
  |
  | Switch scrolling on or off.
  *----------------------------------------###
  turnScroll: (s) ->
    if s is 'off'
      Legwork.$wn.on 'mousewheel', (e) =>
        return false

      Legwork.$doc.on 'keydown', (e) =>
        if e.keyCode in [32..40]
          return false
    else
      Legwork.$wn.off('mousewheel')
      Legwork.$doc.off('keydown')

  ###
  *------------------------------------------*
  | onResizeStart:void (=)
  |
  | Resize has started.
  *----------------------------------------###
  onResizeStart: (e) =>
    @$launch
      .off('mouseenter mouseleave')

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
      for $t, index in @sequenced_stuff
        $t
          .off('activate deactivate')
          .one('activate', @onStuffActivate)

      Legwork.$wn.trigger('scroll')

  ###
  *------------------------------------------*
  | onStuffActivate:void (=)
  |
  | e:object - event object
  |
  | This stuff got activated/deactivated.
  *----------------------------------------###
  onStuffActivate: (e) =>
    $t = $(e.currentTarget)

    if e.type is 'activate'
      @playSequence($t, 'in')
      $t.one('deactivate', @onStuffActivate)
    else
      @playSequence($t, 'out')
      $t.one('activate', @onStuffActivate)

  ###
  *------------------------------------------*
  | onStuffHover:void (=)
  |
  | e:object - event object
  |
  | This stuff got moused with. Get it?
  *----------------------------------------###
  onStuffHover: (e) =>
    $t = $(e.currentTarget)
    $w = $t.find('.ww-hover')
    x = Math.round(e.pageX - $t.offset().left)
    y = Math.round(e.pageY - $t.offset().top)
    w = $t.outerWidth()
    category = @getStuffType($t.parents('.stuff').attr('class'))
    type = e.type
    sequence = if type is 'mouseenter' then 'ww_hover' else category + '_out'

    x = Math.max(Math.min(x, w), 0)
    y = Math.max(Math.min(y, 46), 0)

    $w
      .css({
        'top': y + 'px',
        'left': x + 'px',
        'margin-left': -w + 'px'
      })
      .off('sequence_complete')
      .one 'sequence_complete', (e) =>
        if type is 'mouseenter'
          $t.addClass('over')
        else
          $t.removeClass('over')

        @cell_over.destroy()

    if @cell_over?
      @cell_over.destroy()

      if type is 'mouseenter'
        $t.removeClass('over')
      else
        $t.addClass('over')

    @cell_over = new Legwork.ImageSequence({
      '$el': $w,
      'settings': Legwork.sequences[sequence]
    })

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

    if $t.hasClass('filter') is true
      if $t.hasClass('selected') is true
        $t.removeClass('selected')
        @History.pushState(null, null, '/')
      else
        $('.filter').removeClass('selected')
        $t.addClass('selected')
        @History.pushState(null, null, $t.attr('href'))
    else
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

    @route(url)

  ###
  *------------------------------------------*
  | route:void (-)
  |
  | to:array - url parts
  |
  | Route to the passed url.
  *----------------------------------------###
  route: (to) ->
    if to is ''
      if @current_state is 'detail'
        @resetDetail()

      if @current_state is 'filter'
        @openFilter('')

      Legwork.$wn.trigger('resize')
      @current_state = ''
    else if to in Legwork.filters
      if @current_state is 'detail'
        @resetDetail()
      else
        @openFilter(to)

      @current_state = 'filter'
    else
      if @$detail.is(':visible')
        Legwork.current_detail_controller.deactivate()
        @loadDetail(to)
      else
        @openDetail(to)

      @current_state = 'detail'

  ###
  *------------------------------------------*
  | openDetail:void (-)
  |
  | item:string - work/world id
  |
  | Open the detail view.
  *----------------------------------------###
  openDetail: (item) ->
    @turnScroll('off')

    # Set reference to what you open on
    Legwork.open_detail_state = item

    detail_in = new Legwork.ImageSequence({
      '$el': @$detail,
      'settings': Legwork.sequences['detail_open']
    })

    @$detail
      .css('background-color', 'transparent')
      .show()
      .off('sequence_complete')
      .one 'sequence_complete', (e) =>
        detail_in.destroy()
        @$detail.css('background-color', '#000')
        @loadDetail(item)
        @detailControlsIn()

  ###
  *------------------------------------------*
  | detailControlsIn:void (-)
  |
  | Transition the detail controls in.
  *----------------------------------------###
  detailControlsIn: ()->
    setTimeout =>
      @$detail_close.animate
        'margin-top': '0px'
      ,
        'duration': 500
        'easing': 'easeInOutExpo'
        'step': (now, fx) =>
          @$related_btn.css('margin-bottom', now + 'px')
    , 666

  ###
  *------------------------------------------*
  | loadDetail:void (-)
  |
  | item:string - work/world id
  |
  | Load a detail item.
  *----------------------------------------###
  loadDetail: (item) ->
    model = Legwork.Work[item] or Legwork.World[item]

    if Legwork.slide_controllers[item]?
      controller = Legwork.slide_controllers[item]
    else
      if model.slides.length > 1
        controller = Legwork.slide_controllers[item] = new Legwork.CaseStudyDetail
          model: model
          slug: item
      else
        controller = Legwork.slide_controllers[item] = new Legwork.SingleDetail
          model: model
          slug: item

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
    @turnScroll('on')
    @$detail_close.css('margin-top', '-55px')
    @$related_btn.css('margin-bottom', '-55px')
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
    @$detail_close.attr('href', '/' + filter)

    erase = new Legwork.ImageSequence({
      '$el': @$stuff_reveal,
      'settings': Legwork.sequences['erase']
    })

    # TODO: animate?
    Legwork.$wn.scrollTop(0)

    @$stuff_reveal
      .css('background-color', 'transparent')
      .show()
      .off('sequence_complete')
      .one 'sequence_complete', (e) =>
        @$stuff_reveal.css('background-color', '#fff')
        erase.destroy()

        if filter isnt ''
          @loadFilter(filter)
        else
          @resetFilter()

  ###
  *------------------------------------------*
  | loadFilter:void (-)
  |
  | filter:string - filter id
  |
  | Load a filter.
  *----------------------------------------###
  loadFilter: (filter) ->
    @$canvas_wrap.hide()
    @$stuff_wrap.hide()
    @$filter_wrap
      .empty()
      .show()

    @buildFilter(filter)

    reveal = new Legwork.ImageSequence({
      '$el': @$stuff_reveal,
      'settings': Legwork.sequences['reveal']
    })

    @$stuff_reveal
      .off('sequence_frame')
      .one 'sequence_frame', (e) =>
        setTimeout =>
          @$stuff_reveal.css('background-color', 'transparent')
        , 100
      .off('sequence_complete')
      .one 'sequence_complete', (e) =>
        @$stuff_reveal.hide()
        reveal.destroy()

  ###
  *------------------------------------------*
  | buildFilter:void (-)
  |
  | filter:string - filter id
  |
  | Build a filter.
  *----------------------------------------###
  buildFilter: (filter)->
    manifest = Legwork[filter]
    content = ''

    for stuff, id in manifest.layout
      category = @getStuffType(stuff.type)

      # Content
      switch category
        when 'sequenced'
          content += JST['desktop/templates/sequence'](stuff)
        when 'work', 'world'
          data = Legwork.Work[stuff.content] or Legwork.World[stuff.content]
          data.type = category
          data.link = '/' + stuff.content
          content += JST['desktop/templates/ww'](data)

    # Append to DOM
    @$filter_wrap.append(content)

  ###
  *------------------------------------------*
  | resetFilter:void (-)
  |
  | Back to the initial view.
  *----------------------------------------###
  resetFilter: () ->
    @$filter_wrap.hide()
    @$stuff_wrap.show()

    if Legwork.app_width >= 740
      @$canvas_wrap.show()
      @finishLayout()

    reveal = new Legwork.ImageSequence({
      '$el': @$stuff_reveal,
      'settings': Legwork.sequences['reveal']
    })

    @$stuff_reveal
      .off('sequence_frame')
      .one 'sequence_frame', (e) =>
        setTimeout =>
          @$stuff_reveal.css('background-color', 'transparent')
        , 250
      .off('sequence_complete')
      .one 'sequence_complete', (e) =>
        @$stuff_reveal.hide()
        reveal.destroy()

# Kick the tires and light the fires!
$ ->
  window.application = new Legwork.Application