###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is hot.

###

class Legwork.Loader

  ###
  *------------------------------------------*
  | constructor:void (-)
  |
  | initObj:object - items to load, etc.
  |
  | Construct the fuggin' thing.
  *----------------------------------------###
  constructor: (initObj) ->
    @$el = initObj.$el
    @assets = initObj.assets
    @loaded = 0
    @percent = 0
    @$video_stage = $('#ye-olde-hidden-video-holder')
    Legwork.supports_autoplay = false

    @total = @assets.images.length + @assets.videos.length + @assets.sequences.length + 1 # +1 for Twitter

    @build()

  ###
  *------------------------------------------*
  | build:void (-)
  |
  | DOM manipulations, instantiations, etc.
  *----------------------------------------###
  build: ->
    @testAutoplay()
    @loadTwitter()
    @loadImages()
    @loadSequences()

  ###
  *------------------------------------------*
  | testAutoplay:void (-)
  |
  | Test autoplay capability.
  *----------------------------------------###
  testAutoplay: ->

    # Some machines w/ IE9 can't quite handle
    # the videos due to memory limitations. So,
    # they get some sweet images instead.
    if $('html').hasClass('ie9') is true
      @loadVideo()
      return false

    fail = 0
    failed = false

    $v = $(JST['desktop/templates/html5-video']({
      'path': 'autoplay-test',
      'size': [16, 16],
      'preload': false
    }))
    $v.appendTo(@$video_stage)

    # Fail
    # Note: we are waiting 2s for metadata
    # to load. This should be well within the
    # tolerance for global connection speeds.
    # If this fails, we just show images.
    fail = setTimeout =>
      failed = true
      $v.remove()
      @loadVideo()
    , 2000

    # Succeed
    $v[0].addEventListener 'loadedmetadata', (e) =>
      clearTimeout(fail)

      if failed is false
        Legwork.supports_autoplay = true
        $v.remove()
        @loadVideo()
    , false

    $v[0].load()

  ###
  *------------------------------------------*
  | updateProgress:void (-)
  |
  | Updated the view w/ percent loaded.
  *----------------------------------------###
  updateProgress: () ->
    @percent = Math.round((@loaded / @total) * 100)

    if @loaded is @total
      @loadComplete()

  ###
  *------------------------------------------*
  | loadTwitter:void (-)
  |
  | Load the cached Twitter JSON.
  *----------------------------------------###
  loadTwitter: () ->
    $.getJSON '/tweetyeah', (data) =>
      Legwork.twitter = data

      @loaded++
      @updateProgress()

      # filter replies, could be done server side
      for tweet, index in Legwork.twitter
        if /^(@|\s@|\s\s@|.@|.\s@|RT\s*@)/.test(tweet.text) is true
          Legwork.twitter = _.without(Legwork.twitter, tweet)

  ###
  *------------------------------------------*
  | loadOneImage:void (-)
  |
  | Load one image.
  *----------------------------------------###
  loadOneImage: (image) ->
    $current = $('<img />').attr
      'src': image
    .one 'load', (e) =>
      @loaded++
      @updateProgress()

    if $current[0].complete is true
      $current.trigger('load')

    return $current[0]

  ###
  *------------------------------------------*
  | loadImages:void (-)
  |
  | Preload the specified image collection.
  *----------------------------------------###
  loadImages: ->
    for image in @assets.images
      @loadOneImage(image)

    return false

  ###
  *------------------------------------------*
  | loadSequences:void (-)
  |
  | Preload the specified sequences.
  *----------------------------------------###
  loadSequences: ->
    for sequence in @assets.sequences
      Legwork.sequences[sequence.id] = {
        'fps': sequence.fps,
        'frames': [],
        'base_size': sequence.base_size
      }

      @getSequenceFrames(sequence)

    return false

  ###
  *------------------------------------------*
  | getSequenceFrames:void (-)
  |
  | sequence:object - sequence
  |
  | Get sequence frames.
  *----------------------------------------###
  getSequenceFrames: (sequence) ->
    name = sequence.id

    $.ajax({
      'type': 'GET',
      'dataType': 'JSON',
      'crossDomain': true,
      'url': sequence.src,
      'async': false,
      'success': (data, status, xhr) =>
        Legwork.sequences[name].frames = data

        # Prepare frames
        for i in [0..(Legwork.sequences[name].frames.length - 1)]
          img = new Image()
          img.src = Legwork.sequences[name].frames[i]
          Legwork.sequences[name].frames[i] = img

        @loaded++
        @updateProgress()
      ,
      'error': (data) =>
        debugger
    })

  ###
  *------------------------------------------*
  | loadVideo:void (-)
  |
  | Preload the specified video collection.
  *----------------------------------------###
  loadVideo: ->
    if Modernizr.video and Legwork.supports_autoplay
      for video in @assets.videos
        $v = $(JST['desktop/templates/html5-video'](video))

        $v
          .one('canplay', (e) =>
            @loaded++
            @updateProgress()
          )
          .appendTo(@$video_stage)
          .get(0).load()

        # Max wait for video
        @failsafe($v)
    else
      @loaded += @assets.videos.length
      @updateProgress()

    return false

  ###
  *------------------------------------------*
  | failSafe:void (-)
  |
  | $v:array - jquery object
  |
  | Max video load time.
  *----------------------------------------###
  failsafe: ($v) ->
    setTimeout(=>
      $v.trigger('canplay')
    , 7000)

  ###
  *------------------------------------------*
  | loadComplete:void (-)
  |
  | Loading is finished, cycle status and
  | dispatch Legwork.loaded back to $el
  *----------------------------------------###
  loadComplete: ->
    setTimeout =>
      @$view.fadeOut 600, =>
        @$view.remove()
        @$el.trigger('legwork_load_complete')
    , 1000

  ###
  *------------------------------------------*
  | destroy:void (-)
  |
  | Hey guys, Big Gulps eh? Well, see ya!
  *----------------------------------------###
  destroy: ->
    @$view.remove()
