import std/strutils

import ../../utils/escaping
import ../../utils/genname
import ../../utils/toargs
import ../../../nimtk
import ../widget
import ./widget

type
  TtkLabelFrame* = ref object of TtkWidget

proc isTtkLabelFrame*(w: Widget): bool = "ttklabelframe" in w.pathname.split('.')[^1]

proc newTtkLabelFrame*(parent: Widget, text: string = "", configuration: openArray[(string, string)] = {:}): TtkLabelFrame =
  new result

  result.pathname = pathname(parent.pathname, genName("ttklabelframe_"))
  result.tk = parent.tk

  result.tk.call("ttk::labelframe", result.pathname, {"text": tclEscape text}.toArgs)
  
  if configuration.len > 0:
    result.configure(configuration)

# -text and -underline are provided by ../widget.nim

proc `height=`*(l: TtkLabelFrame, height: int) = l.configure({"height": $height})
proc `labelanchor=`*(l: TtkLabelFrame, labelanchor: AnchorPosition or string) = l.configure({"labelanchor": tclEscape labelanchor})
proc `labelwidget=`*(l: TtkLabelFrame, labelwidget: Widget) = l.configure({"labelwidget": $labelwidget})
proc `width=`*(l: TtkLabelFrame, width: int) = l.configure({"width": $width})

proc height*(l: TtkLabelFrame): int = parseInt l.cget("width")
proc labelanchor*(l: TtkLabelFrame): AnchorPosition = parseEnum[AnchorPosition] l.cget("labelanchor")
proc labelwidget*(l: TtkLabelFrame): Widget = l.tk.newWidgetFromPathname l.cget("labelwidget")
proc width*(l: TtkLabelFrame): int = parseInt l.cget("width")
