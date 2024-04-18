import std/colors

import ./widget
import ../../nimtk

type
  Toplevel* = ref object of Widget

proc newToplevel*(parent: Widget, class: string = "", container: bool = false, visual: string = "", colormap: string = "new", screen: string = "", use: string = ""): Toplevel =
  new result

  result.pathname = pathname(parent.pathname, genName())
  result.tk = parent.tk

  discard result.tk.call(
    "toplevel",
    result.pathname,
    {"class": class, "container": $container, "visual": visual, "colormap": colormap, "screen": screen, "use": use}.toArgs()
  )

#! menu

proc `background=`*(t: Toplevel, background: Color or string) = t.configure({"background": $background & ' '})
proc `height=`*(t: Toplevel, height: string or float or int) = t.configure({"height": $height})
proc `width=`*(t: Toplevel, width: string or float or int) = t.configure({"width": $width})

proc background*(t: Toplevel): Color = parseColor t.cget("background")
proc height*(t: Toplevel): string = t.cget("height")
proc width*(t: Toplevel): string = t.cget("width")