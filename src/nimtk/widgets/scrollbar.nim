import std/sequtils
import std/strutils
import std/colors

import ../utils/escaping
import ../utils/genname
import ../utils/alias
import ../../nimtk
import ./widget

type
  Scrollbar* = ref object of Widget

proc isScrollbar*(w: Widget): bool = "scrollbar" in w.pathname.split('.')[^1]

proc newScrollbar*(parent: Widget, values: openArray[string] = [], configuration: openArray[(string, string)] = {:}): Scrollbar =
  new result

  result.pathname = pathname(parent.pathname, genName("scrollbar_"))
  result.tk = parent.tk

  result.tk.call("scrollbar", result.pathname)
  
  if configuration.len > 0:
    result.configure(configuration)

template linkX*(w: Widget, s: Scrollbar) {.alias: "xscrollbar=".} =
  w.yscrollcommand = $s & " set"
  s.command = $w & " xview"

template linkY*(w: Widget, s: Scrollbar) {.alias: "yscrollbar=".} =
  w.yscrollcommand = $s & " set"
  s.command = $w & " yview"

proc activate*(s: Scrollbar, element: ScrollbarElement) = s.call("activate", element)
proc activate*(s: Scrollbar): ScrollbarElement = parseEnum[ScrollbarElement] s.call("activate")
proc delta*(s: Scrollbar, deltaX, deltaY: int or float) = s.call("delta", deltaX, deltaY)
proc fraction*(s: Scrollbar, x, y: int): float = parseFloat s.call("fraction", x, y)
proc identify*(s: Scrollbar, x, y: int): string = s.call("identify", x, y)
proc set*(s: Scrollbar, first, last: float) = s.call("set", first, last)
proc get*(s: Scrollbar): array[2, float] {.alias: "text".} =
  s.call("get")

  let res = s.tk.result.split(' ').map(parseFloat)

  result[0] = res[0]
  result[1] = res[1]

proc `activerelief=`*(s: Scrollbar, activerelief: WidgetRelief) = s.configure({"activerelief": $activerelief})
proc `command=`*(s: Scrollbar, command: string) = s.configure({"command": '{' & $(command).tclEscape()[1..^2] & '}'})
proc `elementborderwidth=`*(s: Scrollbar, elementborderwidth: int or string) = s.configure({"elementborderwidth": $elementborderwidth})
proc `width=`*(s: Scrollbar, width: int or string) = s.configure({"width": $width})

proc activerelief*(s: Scrollbar): WidgetRelief = parseEnum[WidgetRelief] s.cget("activerelief")
proc command*(s: Scrollbar): string = s.cget("command")
proc elementborderwidth*(s: Scrollbar): string = s.cget("elementborderwidth")
proc width*(s: Scrollbar): string = s.cget("width")
