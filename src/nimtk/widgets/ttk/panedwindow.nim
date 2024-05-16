import std/sequtils
import std/strutils
import std/colors

import ../../utils/escaping
import ../../utils/genname
import ../../utils/toargs
import ../../utils/alias
import ../../../nimtk
import ../widget
import ./widget

type
  TtkPanedWindow* = ref object of Widget

proc isTtkPanedWindow*(w: Widget): bool = "ttkpanedwindow" in w.pathname.split('.')[^1]

proc newTtkPanedWindow*(parent: Widget, orient: WidgetOrientation = WidgetOrientation.Horizontal, configuration: openArray[(string, string)] = {:}): TtkPanedWindow =
  new result

  result.pathname = pathname(parent.pathname, genName("ttkpanedwindow_"))
  result.tk = parent.tk

  result.tk.call("ttk::panedwindow", result.pathname, {"orient": $orient}.toArgs)

  if configuration.len > 0:
    result.configure(configuration)

proc add*(p: TtkPanedWindow, window: Widget, weight: int = 0) = p.tk.call($p, "add", window, {"weight": $weight}.toArgs)
proc insert*(p: TtkPanedWindow, pos: string or int or Widget, window: Widget, weight: int = 0) = p.tk.call($p, "insert", tclEscape pos, window, {"weight": $weight}.toArgs)
proc forget*(p: TtkPanedWindow, window: Widget) = p.tk.call($p, "forget", window)
proc identifySash*(p: TtkPanedWindow, x, y: int): int =
  ## Returns -1 if no component is present at location (x, y)

  try:
    parseInt p.tk.call($p, "identify sash", x, y)
  except ValueError:
    -1
# identifyElement from ./widget.nim
proc paneweight*(p: TtkPanedWindow, pane: int or Widget): int = parseInt p.tk.call($p, "pane", pane, {"weight": " "}.toArgs)
proc pane*(
  p: TtkPanedWindow,
  pane: int or Widget,
  
  weight: int
) = 
  p.tk.call(
    $p, "pane", pane,
    {"weight": $weight}.toArgs
  )
proc panes*(p: TtkPanedWindow): seq[Widget] =
  let res = p.tk.call($p, "panes").split(' ')

  for i in res:
    result.add(p.tk.newWidgetFromPathname i)
proc `[]`*(p: TtkPanedWindow, idx: int): Widget {.inline.} = p.panes[idx]
proc sashPos*(p: TtkPanedWindow, index: int): int = parseInt p.tk.call($p, "sashpos", index)
proc sashPos*(p: TtkPanedWindow, index: int, newPos: int): int {.alias: "sashPos=".} = parseInt p.tk.call($p, "sashpos", index, newPos)

proc `height=`*(p: TtkPanedWindow, height: int or string or float) = p.configure({"height":  tclEscape height})
proc `width=`*(p: TtkPanedWindow, width: int or string or float) = p.configure({"width":  tclEscape width})

proc height*(p: TtkPanedWindow): string = p.cget("height")
proc width*(p: TtkPanedWindow): string = p.cget("width")

