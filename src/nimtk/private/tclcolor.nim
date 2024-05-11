# TODO merge with tcllist?

import std/sequtils
import std/strutils
import std/colors

import ../../nimtk
import ./escaping

proc fromTclColor*[W](w: W, tclColor: string): Color =
  ## Get `colors.Color` from color string returned from Tk
  ## 
  ## This is needed if Tk returns, for example, "systemDefault" from a command,
  ## which cannot be parsed via just `parseColor`
  ##
  ## For all colors returned from Tk, please use this proc and not `parseColor`.

  # if the color is already a normal HTML code color...
  if tclColor[0] == '#' and tclColor.len == 7:
    return parseColor tclColor

  # else, use winfo to get the exact 16-bit rgb values
  let rgb = w.tk.call("winfo rgb", w, tclEscape tclColor)
    .split(' ')
    .map(parseInt)
  
  # the values returned are 16-bit, so we shift them right by 8 bits
  # to get the 8 bit value we need for `colors.rgb`
  return colors.rgb(
    (rgb[0] shr 8).clamp(0, 255),
    (rgb[1] shr 8).clamp(0, 255),
    (rgb[2] shr 8).clamp(0, 255)
  )
