import std/strutils
import std/colors

import ../utils/escaping
import ../utils/tclcolor
import ../utils/genname
import ../utils/toargs
import ../../nimtk
import ./widget
import ./label

type
  LabelFrame* = ref object of Widget

proc isLabelFrame*(w: Widget): bool = "labelframe" in w.pathname.split('.')[^1]

proc newLabelFrame*(parent: Widget, text: string, class: string = "", visual: string = "default", colormap: string = "new"): LabelFrame =
  new result

  result.pathname = pathname(parent.pathname, genName("labelframe_"))
  result.tk = parent.tk

  discard result.tk.call(
    "labelframe",
    result.pathname,
    {"text": tclEscape text}.toArgs(),
    {"class": class, "visual": visual, "colormap": colormap}.toArgs()
  )

proc `labelwidget=`*(l: LabelFrame, labelwidget: Label) = l.configure({"labelwidget": $labelwidget})
proc `labelanchor=`*(l: LabelFrame, anchor: AnchorPosition) = l.configure({"labelanchor": $anchor})
proc `background=`*(l: LabelFrame, background: Color or string) = l.configure({"background": $background & ' '})
proc `height=`*(l: LabelFrame, height: string or float or int) = l.configure({"height": $height})
proc `width=`*(l: LabelFrame, width: string or float or int) = l.configure({"width": $width})

proc anchor*(l: LabelFrame): AnchorPosition = parseEnum[AnchorPosition] l.cget("labelanchor")
proc background*(l: LabelFrame): Color = fromTclColor l, l.cget("background")
proc height*(l: LabelFrame): string = l.cget("height")
proc width*(l: LabelFrame): string = l.cget("width")
proc labelwidget*(l: LabelFrame): Label = 
  new result

  result.tk = l.tk
  result.pathname = l.cget("labelwidget")
