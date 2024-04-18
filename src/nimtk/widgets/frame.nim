import std/colors

import ./widget
import ../../nimtk

type
  Frame* = ref object of Widget

proc newFrame*(parent: Widget, class: string = "", container: bool = false, visual: string = "default", colormap: string = "new"): Frame =
  new result

  result.pathname = pathname(parent.pathname, genName("frame_"))
  result.tk = parent.tk

  discard result.tk.call(
    "frame",
    result.pathname,
    {"class": class, "container": $container, "visual": visual, "colormap": colormap}.toArgs()
  )

proc `background=`*(f: Frame, background: Color or string) = f.configure({"background": $background & ' '})
proc `height=`*(f: Frame, height: string or float or int) = f.configure({"height": $height})
proc `width=`*(f: Frame, width: string or float or int) = f.configure({"width": $width})

proc background*(f: Frame): Color = parseColor f.cget("background")
proc height*(f: Frame): string = f.cget("height")
proc width*(f: Frame): string = f.cget("width")
