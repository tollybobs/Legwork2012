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
    @supports_autoplay = false

    @total = @assets.images.length + @assets.videos.length + 1 # +1 for Twitter

    for sequence in @assets.sequences
      @total += sequence.frames.length

    @testAutoplay()
    @build()


  ###
  *------------------------------------------*
  | testAutoplay:void (-)
  |
  | Test autoplay capability.
  *----------------------------------------###
  testAutoplay: ->
    success = 0
    fail = 0
    failed = false

    $v = $(JST['desktop/templates/html5-video']({
      'path': 'autoplay-test',
      'size': [16, 16],
      'preload': false
    }))
    $v.appendTo(@$video_stage)

    # Fail
    # Note: I am seeing times consistently under 100ms
    # for the loadstart event to fire. According to W3C,
    # when this event fires shouldn't be bandwidth
    # dependent. 500ms should cover almost any case.
    fail = setTimeout =>
      failed = true
      $v.remove()
      @loadVideo()
    , 500

    # Succeed
    $v[0].addEventListener 'loadstart', =>
      b = new Date().getTime()
      console.log(b - a)

      clearTimeout(fail)

      if failed is false
        @supports_autoplay = true
        $v.remove()
        @loadVideo()
    , false

    a = new Date().getTime()
    $v[0].load()

  ###
  *------------------------------------------*
  | build:void (-)
  |
  | DOM manipulations, instantiations, etc.
  *----------------------------------------###
  build: ->
    @loadTwitter()
    @loadImages()
    @loadSequences()

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
    # TODO: cache this shit on our side
    # TODO: in case of failure?
    $.getJSON '/tweetyeah', (data) =>
      Legwork.twitter = data

      # filter replies, could be done server side
      for tweet, index in Legwork.twitter
        if /^(@|\s@|\s\s@|.@|.\s@)/.test(tweet.text) is true
          Legwork.twitter = _.without(Legwork.twitter, tweet)

        @loaded++
        @updateProgress()

  ###
  *------------------------------------------*
  | loadOneImage:void (-)
  |
  | Load one image.
  *----------------------------------------###
  loadOneImage: (image) ->
    $current = $('<img />').attr
      'src': image
    .one 'load', {'path': image}, (e) =>
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
        'frames': []
      }

      for image, index in sequence.frames
        Legwork.sequences[sequence.id].frames.push(@loadOneImage(image))

    return false

  ###
  *------------------------------------------*
  | loadVideo:void (-)
  |
  | Preload the specified video collection.
  *----------------------------------------###
  loadVideo: ->
    if Modernizr.video and @supports_autoplay
      for video in @assets.videos
        $v = $(JST['desktop/templates/html5-video'](video))
        $v.appendTo(@$video_stage)

        $v[0].addEventListener 'canplaythrough', =>
          @loaded++
          @updateProgress()

        , false
    else
      @loaded += @assets.videos.length
      @updateProgress()

    return false

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
    # TODO: cancel loading?
    @$view.remove()
