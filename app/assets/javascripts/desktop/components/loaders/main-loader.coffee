###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is hot.

###

class Legwork.MainLoader extends Legwork.Loader

  ###
  *------------------------------------------*
  | override constructor:void (-)
  |
  | initObj:object - items to load, etc.
  |
  | Construct the fuggin' thing.
  *----------------------------------------###
  constructor: (initObj) ->
    @start = [
      'Hey.',
      'What are you doing here?',
      'Well, the site is loading again.'
    ]

    @random = [
      'These dudes suck at SEO<sup>TM</sup>.',
      'I hope they remembered thier meta keywords.',
      'I don\'t think there is a robots.txt file.',
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

    super(initObj)

  ###
  *------------------------------------------*
  | override build:void (-)
  |
  | DOM manipulations, instantiations, etc.
  *----------------------------------------###
  build: ->
    @$view = $(JST['desktop/templates/main-loader']())
    @$el.append(@$view)

    # Loader view DOM refs
    @$fill = @$view.find('#loader-fill')
    @$status = @$view.find('#loader-status')
    @$bros = @$view.find('#loader-bros')
    @$speech_bubble = @$view.find('#loader-speech-bubble')

    # Talk
    @talk = setTimeout =>
      @updateConversation()
    , 2000

    super()

  ###
  *------------------------------------------*
  | override updateProgress:void (-)
  |
  | Updated the view w/ percent loaded.
  *----------------------------------------###
  updateProgress: () ->
    super()
    $('#loader-fill').css('height', @percent + '%')

  ###
  *------------------------------------------*
  | updateConversation:void (-)
  |
  | Update the speech bubbles.
  *----------------------------------------###
  updateConversation: ->
    msg = if @interval <= 2 then @start[@interval] else @getRandomMessage()

    @$speech_bubble
      .hide()
      .toggleClass('right')
      .toggleClass('left')
      .find('span')
      .html(msg)

    @show = setTimeout =>
      @$speech_bubble.show()
    , 1000

    @talk = setTimeout =>
      @interval += 1
      @updateConversation()
    , if msg.length * 120 < 3000 then 3000 else msg.length * 120

  ###
  *------------------------------------------*
  | getRandomMessage:string (-)
  |
  | Return a different random message from
  | the last one.
  *----------------------------------------###
  getRandomMessage: ->
    @prev_rand = @rand

    while @prev_rand is @rand
      @rand = Math.round(Math.random() * (@random.length - 1))

    return @random[@rand]

  ###
  *------------------------------------------*
  | override loadComplete:void (-)
  |
  | Loading is finished, cycle status and
  | dispatch Legwork.loaded back to $el
  *----------------------------------------###
  loadComplete: ->
    clearTimeout(@talk)
    clearTimeout(@show)
    @$speech_bubble.hide()
    Legwork.$wrapper.show()

    @$bros
      .animate
        'bottom':'-325px'
      ,
        'duration':666
        'easing':'easeInExpo'
        'step': (now, fx) =>
          p = Math.abs(now) / 325

          @$status.css
            'opacity':1 - p
        'complete': (e) =>
          @$el.trigger('legwork_load_complete')
          @$view.remove()