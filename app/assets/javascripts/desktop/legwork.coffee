class Legwork.Application

  constructor: ->
    # Class vars
    @$wn = $(window)
    @$doc = $(document)
    @$html = $('html')
    @$body = $('body')
    @$wrapper = $('#wrapper')

    @observeSomeSweetEvents()

  observeSomeSweetEvents: ->
    

$ ->
  window.application = new Legwork.Application