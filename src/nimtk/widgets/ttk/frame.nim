import std/strutils

import ../../utils/genname
import ../../utils/toargs
import ../../../nimtk
import ../widget
import ./widget

type
  TtkFrame* = ref object of TtkWidget

proc isTtkFrame*(w: Widget): bool = "ttkframe" in w.pathname.split('.')[^1]

proc newTtkFrame*(parent: Widget, configuration: openArray[(string, string)] = {:}): TtkFrame =
  new result

  result.pathname = pathname(parent.pathname, genName("ttkframe_"))
  result.tk = parent.tk

  result.tk.call("ttk::frame", result.pathname)
  
  if configuration.len > 0:
    result.configure(configuration)

# -relief and -borderwidth are already provided by ../widget.nim

proc `width=`*(f: TtkFrame, width: int) = f.configure({"width": $width})
proc `height=`*(f: TtkFrame, height: int) = f.configure({"height": $height})

proc width*(f: TtkFrame): int = parseInt f.cget("width")
proc height*(f: TtkFrame): int = parseInt f.cget("width")
