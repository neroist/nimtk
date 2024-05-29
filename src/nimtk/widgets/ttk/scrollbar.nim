import std/sequtils
import std/strutils
import std/colors

import ../../utils/escaping
import ../../utils/genname
import ../../utils/toargs
import ../../utils/alias
import ../../../nimtk
import ../widget

type
  TtkScrollbar* = ref object of Widget

proc isTtkScrollbar*(w: Widget): bool = "ttkscrollbar" in w.pathname.split('.')[^1]

proc newTtkScrollbar*(parent: Widget, orient: WidgetOrientation = woVertical, configuration: openArray[(string, string)] = {:}): TtkScrollbar =
  new result

  result.pathname = pathname(parent.pathname, genName("ttkscrollbar_"))
  result.tk = parent.tk

  result.tk.call("ttk::scrollbar", result.pathname, {"orient": $orient}.toArgs)
  
  if configuration.len > 0:
    result.configure(configuration)

proc newHorizontalTtkScrollbar*(parent: Widget, configuration: openArray[(string, string)] = {:}): TtkScrollbar =
  newTtkScrollbar(parent, woHorizontal, configuration)

proc newVerticalTtkScrollbar*(parent: Widget, configuration: openArray[(string, string)] = {:}): TtkScrollbar =
  newTtkScrollbar(parent, woVertical, configuration)

template linkX*(w: Widget, s: TtkScrollbar) {.alias: "xscrollbar=".} =
  w.yscrollcommand = $s & " set"
  s.command = $w & " xview"

template linkY*(w: Widget, s: TtkScrollbar) {.alias: "yscrollbar=".} =
  w.yscrollcommand = $s & " set"
  s.command = $w & " yview"

proc delta*(s: TtkScrollbar, deltaX, deltaY: int or float) = s.call("delta", deltaX, deltaY)
proc fraction*(s: TtkScrollbar, x, y: int): float = parseFloat s.call("fraction", x, y)
proc identify*(s: TtkScrollbar, x, y: int): string = s.call("identify", x, y)
proc set*(s: TtkScrollbar, first, last: float) = s.call("set", first, last)
proc get*(s: TtkScrollbar): array[2, float] {.alias: "text".} =
  s.call("get")

  let res = s.tk.result.split(' ').map(parseFloat)

  result[0] = res[0]
  result[1] = res[1]
proc moveto*(s: TtkScrollbar, fraction: float) = s.call("moveto", fraction)
proc scrollUnits*(s: TtkScrollbar, number: int) = s.call("scroll", number, "units")
proc scrollPages*(s: TtkScrollbar, number: int) = s.call("scroll", number, "pages")

proc `command=`*(s: TtkScrollbar, command: string) = s.configure({"command": '{' & $(command).tclEscape()[1..^2] & '}'})

proc command*(s: TtkScrollbar): string = s.cget("command")
