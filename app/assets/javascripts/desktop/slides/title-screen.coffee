###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is still hot.

###

#= require ./slide

class Legwork.Slides.TitleScreen extends Legwork.Slides.Slide

  ###
  *------------------------------------------*
  | constructor:void (-)
  |
  | options:object - initialization object
  |
  | Construct the fuggin' thing.
  *----------------------------------------###
  constructor: (options) ->
    # POWERFUL!
    super(options)

  ###
  *------------------------------------------*
  | activate:void (-)
  |
  | Activate new/current slide
  *----------------------------------------###
  activate: ->
    console.log('Legwork.Slides.TitleScreen :: activate')

  ###
  *------------------------------------------*
  | deactivate:void (-)
  |
  | Deactivate old slide
  *----------------------------------------###
  deactivate: ->
    console.log('Legwork.Slides.TitleScreen :: deactivate')