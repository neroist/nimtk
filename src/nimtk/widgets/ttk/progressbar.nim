import std/strutils

import ../../utils/escaping
import ../../utils/genname
import ../../utils/toargs
import ../../variables
import ../../../nimtk
import ../widget
import ./widget

type
  ProgressBar* = ref object of TtkWidget

proc isProgressBar*(w: Widget): bool = "progressbar" in w.pathname.split('.')[^1]

proc newProgressBar*(parent: Widget, maximum: int or float = 100, orient: WidgetOrientation = woHorizontal, configuration: openArray[(string, string)] = {:}): ProgressBar =
  new result

  result.pathname = pathname(parent.pathname, genName("progressbar_"))
  result.tk = parent.tk

  result.tk.call("ttk::progressbar", result.pathname, {"maximum": $maximum, "orient": $orient}.toArgs())
  
  if configuration.len > 0:
    result.configure(configuration)

proc newHorizontalProgressBar*(parent: Widget, maximum: int or float = 100, configuration: openArray[(string, string)] = {:}): ProgressBar =
  newProgressBar(parent, maximum, woHorizontal, configuration)

proc newVerticalProgressBar*(parent: Widget, maximum: int or float = 100, configuration: openArray[(string, string)] = {:}): ProgressBar =
  newProgressBar(parent, maximum, woVertical, configuration)

proc identify*(p: ProgressBar, x, y: int): string = p.call("identify", x, y)
#? Use instate by ./widget.nim?
proc start*(p: ProgressBar, interval: int = 50) = p.call("start", interval)
#? Use state by ./widget.nim?
proc step*(p: ProgressBar, amount: int or float = 1) = p.call("step", amount)
proc stop*(p: ProgressBar) = p.call("stop")

proc `length=`*(p: ProgressBar, length: int) = p.configure({"length": $length})
proc `maximum=`*(p: ProgressBar, maximum: int or float) = p.configure({"maximum": $maximum})
proc `mode=`*(p: ProgressBar, mode: ProgressBarMode or string) = p.configure({"mode": tclEscape mode})
# orient from ../widget.nim
proc `value=`*(p: ProgressBar, value: int or float) = p.configure({"value": $value})
proc `variable=`*(p: ProgressBar, variable: TkInt or TkFloat) = p.configure({"variable": variable.varname})

proc length*(p: ProgressBar): float = parseFloat p.cget("length")
proc maximum*(p: ProgressBar): float = parseFloat p.cget("maximum")
proc mode*(p: ProgressBar): ProgressBarMode = parseEnum[ProgressBarMode] p.cget("mode")
proc phase*(p: ProgressBar): float = parseFloat p.cget("phase")
proc value*(p: ProgressBar): float = parseFloat p.cget("value")
proc variable*(p: ProgressBar): TkVar = createTkVar p.tk, p.cget("variable")
