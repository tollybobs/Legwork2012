###

Copyright (c) 2012 Legwork Studio. All Rights Reserved.

###

#= require ./slide

class Legwork.Slides.FullScreenImage extends Legwork.Slides.Slide

  ###
  *------------------------------------------*
  | constructor:void (-)
  |
  | options:object - initialization object
  |
  | Construct the fuggin' thing.
  *----------------------------------------###
  constructor: (options) ->
    super(options)

  ###
  *------------------------------------------*
  | build:$el (-)
  |
  | Build DOM based on model.
  *----------------------------------------###
  build: ->
    @$el = @renderTemplate('full-screen-image', @model)
    return @$el