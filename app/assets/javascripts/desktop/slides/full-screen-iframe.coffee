###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is still hot.

###

#= require ./slide

class Legwork.Slides.FullScreenIframe extends Legwork.Slides.Slide

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
  | build:$el (-)
  |
  | Build DOM based on model.
  *----------------------------------------###
  build: ->
    @$el = @renderTemplate('full-screen-iframe', @model)
    @url = @$el.data('url')
    @mobile = false
    return @$el

  ###
  *------------------------------------------*
  | activate:void (-)
  |
  | Activate new/current slide
  *----------------------------------------###
  activate: ->
    if $('iframe', @$el).length > 0
      $('iframe', @$el).remove()
      console.log('remove first')

    @$el.empty().append("<iframe src='#{@url}' height='100%' width='100%'></iframe>")
    # Legwork.$wn.trigger('resize')

  ###
  *------------------------------------------*
  | deactivate:void (-)
  |
  | Deactivate old slide
  *----------------------------------------###
  deactivate: ->
    $('iframe', @$el).fadeOut 333, =>
      @$el.empty()

  ###
  *------------------------------------------*
  | onResize:void (=)
  |
  | w:number - window width
  | h:number - window height
  |
  | Handle window resize
  *----------------------------------------###
  # resize: (w, h) =>
  #   super(w, h)
      
  #   if w < 740
  #     if @mobile is false
  #       @mobile = true
  #       @$el.empty().append("<iframe src='#{@url}/mobile' height='100%' width='100%'></iframe>")
  #       console.log(@mobile)
  #   else
  #     if @mobile is true
  #       @mobile = false
  #       @$el.empty().append("<iframe src='#{@url}' height='100%' width='100%'></iframe>")
  #       console.log(@mobile)





