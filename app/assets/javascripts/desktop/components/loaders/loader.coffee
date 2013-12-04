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

    # Test
    @videos_loaded = 0
    @videos_total = @assets.videos.length

    @total = @assets.images.length + @assets.videos.length + 1 # +1 for Twitter

    for sequence in @assets.sequences
      @total += sequence.frames.length
      @images_total += sequence.frames.length

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

      ###
      console.log('Loaded Twitter 1/1')
      ###

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
    if Modernizr.video and Legwork.supports_autoplay
      for video in @assets.videos
        $v = $(JST['desktop/templates/html5-video'](video))
        $v.appendTo(@$video_stage)

        console.log('Started loading ' + video.path)

        $v.one 'canplay', (e) =>
          @loaded++
          @updateProgress()

          @videos_loaded++
          console.log('Loaded video ' + @videos_loaded + '/' + @videos_total + ' : ' + $(e.currentTarget).attr('id'))

        $v[0].load()
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
    @$view.remove()
