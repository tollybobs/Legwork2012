###

Copyright (c) 2012 Legwork Studio. All Rights Reserved. Your wife is hot.

###

class Legwork.VectorUtils

  ###
  *------------------------------------------*
  | constructor:void (-)
  |
  | Construct the fuggin' thing.
  *----------------------------------------###
  constructor: ->

  ###
  *------------------------------------------*
  | sqr:number (-)
  |
  | a:number - number to square
  |
  | Square a number.
  *----------------------------------------###
  sqr: (a) ->
    return a * a

  ###
  *------------------------------------------*
  | add:vector (-)
  |
  | a:vector
  | b:vector
  |
  | Add two vectors.
  *----------------------------------------###
  add: (a, b) -> 
    c = []

    for i in [0..(a.length - 1)]
      c[i] = a[i] + b[i]

    return c

  ###
  *------------------------------------------*
  | subtract:vector (-)
  |
  | a:vector
  | b:vector
  |
  | Subtract two vectors.
  *----------------------------------------###
  subtract: (a, b) ->
    c = []

    for i in [0..(a.length - 1)]
      c[i] = a[i] - b[i]

    return c

  ###
  *------------------------------------------*
  | multiply:vector (-)
  |
  | a:vector
  | b:vector
  |
  | Multiply two vectors.
  *----------------------------------------###
  multiply: (a, b) ->
    c = []

    for i in [0..(a.length - 1)]
      c[i] = a[i] * b[i]

    return c

  ###
  *------------------------------------------*
  | normalize:vector (-)
  |
  | a:vector
  |
  | Normalize.
  *----------------------------------------###
  normalize: (a) ->
    b = []

    b[0] = a[0] / Math.sqrt(@sqr(a[0]) + @sqr(a[1]))
    b[1] = a[1] / Math.sqrt(@sqr(a[0]) + @sqr(a[1]))

    return b