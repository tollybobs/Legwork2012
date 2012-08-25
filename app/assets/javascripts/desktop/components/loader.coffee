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
    #@$el = initObj.$el
    #@assets = initObj.assets

    @start = [
      'Hey.',
      'What are you doing here?',
      'Well the fucking site is loading again.'
    ]

    @random = [
      'These dudes suck at SEO<sup>TM</sup>.',
      'I hope they remembered thier meta keywords.',
      'Shit, I don\'t think there is a fucking robots.txt file.',
      'This page has too many http requests.',
      'Man, I hate preloaders. Want to get out of here?',
      'No support for IE8? Good luck getting customers.',
      'I just went from six to midnight.',
      'I just sent an http request to Dean Boyer\'s mom.',
      'It doesn\'t even work on my Blackberry.',
      'I think HTML5 parallax sites are the best.'
    ]

    @interval = 0
    @rand = 0
    @prev_rand = 0

    setTimeout =>
      @updateSpeech()
    , 2000

  updateSpeech: ->
    @prev_rand = @rand

    while @prev_rand is @rand
      @rand = Math.round(Math.random() * (@random.length - 1))

    msg = if @interval <= 2 then @start[@interval] else @random[@rand]

    $('#speech-bubble')
      .hide()
      .toggleClass('right')
      .toggleClass('left')
      .find('span')
      .html(msg)

    @speech_to = setTimeout ->
      $('#speech-bubble').show()
    , 1000

    @interval += 1

    if @interval <= 5
      setTimeout =>
        @updateSpeech()
      , if msg.length * 120 < 3000 then 3000 else msg.length * 120
    else
      clearTimeout(@speech_to)
      $('#status').text('')

      $('#bros')
        .animate
          'bottom':'-325px'
        ,
          'duration':666
          'easing':'easeInExpo'
          'step': (now, fx) =>
            p = Math.abs(now) / 325

            $('#status').css
              'opacity':1 - p
          'complete': (e) ->
            $('#bands').animate
              'width':'100%'
            , 333, 'easeInExpo', =>
              $('#main-loader').animate
                'margin-left':'100%'
              , 333, 'easeOutExpo', ->
                $(this).remove()

                $('header').find('h1')
                  .delay(250)
                  .animate
                    'margin-bottom':'0px'
                  , 666, 'easeInOutExpo'

              $('#legwork').delay(166).animate
                'width':'100%'
              , 333, 'easeInOutExpo'

    #@build(initObj.type)
    #@loadImages()

  ###
  *------------------------------------------*
  | build:void (-)
  |
  | type:string - type for template ref
  |
  | DOM manipulations, instantiations, etc.
  *----------------------------------------###
  build: (type) ->
    @$view = $(_.template(ParaNorman.templates[type + '_loader'], {}))
    @$el.append(@$view)

    # Loader view DOM refs
    @$status = @$view.find('.status')
    @$images =  @$status.find('.images')
    @$video = @$status.find('.video')
    @$complete = @$status.find('.complete')

  ###
  *------------------------------------------*
  | loadImages:void (-)
  |
  | Preload the specified image collection.
  *----------------------------------------###
  loadImages: ->
    checklist = @assets.images

    if checklist.length isnt 0
      @$images.animate
        'top':'0px'
      , 400, 'easeOutExpo'
      
      for image in @assets.images
        $current = $('<img />').attr
          'src': image
        .one 'load', {'path': image}, (e) =>
          checklist = _.without(checklist, e.data.path)
          if checklist.length is 0
            @imagesComplete()

        if $current[0].complete is true
          $current.trigger('load')
    else
      @loadVideo()

    return false

  ###
  *------------------------------------------*
  | loadVideo:void (-)
  |
  | Preload the specified video collection.
  *----------------------------------------###
  loadVideo: ->
    if @assets.video.length isnt 0 and Modernizr.video
      @$video.animate
        'top':'0px'
      , 400, 'easeOutExpo'

      # TODO: abstract video loader
      @videoComplete()

      ###
      $vid = $(_.template(ParaNorman.templates.video, {'w':'1300', 'h':'560', 'id':'raise-the-judge', 'path':@assets.video[0]}))
      $vid.appendTo('body')

      $vid[0].addEventListener 'canplaythrough', =>
        @videoComplete()
        $vid[0].removeEventListener 'canplaythrough'
      , false
      ###
    else
      @loadComplete()

    return false

  ###
  *------------------------------------------*
  | imagesComplete:void (-)
  |
  | Images are done, cycle status and cont.
  *----------------------------------------###
  imagesComplete: ->
    @$images.animate
      'top':'-20px'
    , 400, 'easeInExpo', =>
      setTimeout @loadVideo, 200
      return false

  ###
  *------------------------------------------*
  | videoComplete:void (-)
  |
  | Videos are done, cycle status and cont.
  *----------------------------------------###
  videoComplete: ->
    @$video.animate
      'top':'-20px'
    , 400, 'easeInExpo', =>
      setTimeout @loadComplete, 200
      return false

  ###
  *------------------------------------------*
  | loadComplete:void (-)
  |
  | Loading is finished, cycle status and
  | dispatch Legwork.loaded back to $el
  *----------------------------------------###
  loadComplete: ->
    @$complete.animate
      'top':'0px'
    , 400, 'easeOutExpo'

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
    clearTimeout(@lt)
    @$view.remove()
