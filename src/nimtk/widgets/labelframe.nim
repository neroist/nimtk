import std/strutils

import std/colors

import ./label
import ./widget
import ../nimtk

type
  LabelFrame* = ref object of Widget

proc newLabelFrame*(parent: Widget, class: string = "", visual: string = "default", colormap: string = "new"): LabelFrame =
  new result

  result.pathname = pathname(parent.pathname, genName())
  result.tk = parent.tk

  discard result.tk.call(
    "labelframe",
    result.pathname,
    {"class": class, "visual": visual, "colormap": colormap}.toArgs()
  )

proc `labelwidget=`*(l: LabelFrame, labelwidget: Label) = l.configure({"labelwidget": $labelwidget})
proc `labelanchor=`*(l: LabelFrame, anchor: AnchorPosition) = l.configure({"labelanchor": $anchor})
proc `background=`*(f: LabelFrame, background: Color or string) = f.configure({"background": $background & ' '})
proc `height=`*(f: LabelFrame, height: string or float or int) = f.configure({"height": $height})
proc `width=`*(f: LabelFrame, width: string or float or int) = f.configure({"width": $width})

proc anchor*(l: LabelFrame): AnchorPosition = parseEnum[AnchorPosition] l.cget("labelanchor")
proc background*(f: LabelFrame): Color = parseColor f.cget("background")
proc height*(f: LabelFrame): string = f.cget("height")
proc width*(f: LabelFrame): string = f.cget("width")
proc labelwidget*(l: LabelFrame): Label =
  new result

  result.pathname = l.cget("labelwidget")
  result.tk = l.tk
