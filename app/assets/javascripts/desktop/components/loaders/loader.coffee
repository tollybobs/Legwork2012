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
    @percent = 0

    @build()
    @loadImages()

  ###
  *------------------------------------------*
  | build:void (-)
  |
  | DOM manipulations, instantiations, etc.
  *----------------------------------------###
  build: ->

  ###
  *------------------------------------------*
  | updateProgress:void (-)
  |
  | Updated the view w/ percent loaded.
  *----------------------------------------###
  updateProgress: (p) ->
    @percent = p

  ###
  *------------------------------------------*
  | loadImages:void (-)
  |
  | Preload the specified image collection.
  *----------------------------------------###
  loadImages: ->
    checklist = @assets.images

    if checklist.length isnt 0
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
    if @assets.videos.length isnt 0 and Modernizr.video

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
  | Images are done, update status and cont.
  *----------------------------------------###
  imagesComplete: ->
    @loadVideo()
    return false

  ###
  *------------------------------------------*
  | videoComplete:void (-)
  |
  | Videos are done, update status and cont.
  *----------------------------------------###
  videoComplete: ->
    @loadComplete()
    return false

  ###
  *------------------------------------------*
  | loadComplete:void (-)
  |
  | Loading is finished, cycle status and
  | dispatch Legwork.loaded back to $el
  *----------------------------------------###
  loadComplete: ->
    @updateProgress(100)

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
