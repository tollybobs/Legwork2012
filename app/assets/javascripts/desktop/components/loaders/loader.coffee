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
    @supports_autoplay = (->
      # TODO: stronger test
      if navigator.userAgent.match(/iPhone/i) or navigator.userAgent.match(/iPod/i) or navigator.userAgent.match(/iPad/i)
        return false
      else
        return true
    )()

    @addSequences()

    @total = @assets.images.length + @assets.videos.length + 1 # +1 for Twitter

    @build()

  ###
  *------------------------------------------*
  | addSequences:void (-)
  |
  | Add sequences to the images array.
  *----------------------------------------###
  addSequences: ->
    for sequence in @assets.sequences
      Legwork.sequences[sequence.id] = sequence
      @assets.images = _.union(@assets.images, sequence.frames)

  ###
  *------------------------------------------*
  | build:void (-)
  |
  | DOM manipulations, instantiations, etc.
  *----------------------------------------###
  build: ->
    @loadTwitter()
    @loadImages()
    @loadVideo()

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
        if ///^(@|\s@|\s\s@|.@|.\s@)///.test(tweet.text) is true
          Legwork.twitter = _.without(Legwork.twitter, tweet)

        @loaded++
        @updateProgress()

  ###
  *------------------------------------------*
  | loadImages:void (-)
  |
  | Preload the specified image collection.
  *----------------------------------------###
  loadImages: ->
    for image in @assets.images
      $current = $('<img />').attr
        'src': image
      .one 'load', {'path': image}, (e) =>
        @loaded++
        @updateProgress()

      if $current[0].complete is true
        $current.trigger('load')

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
        @$el.trigger('Legwork.loaded')
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
