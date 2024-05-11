import std/strutils
import std/colors

import ../private/toargs
import ../../nimtk
import ./widget
import ./root
import ./menu

type
  Toplevel* = ref object of Widget

proc isToplevel*(w: Widget): bool = "toplevel" in w.pathname.split('.')[^1]

proc newToplevel*(parent: Widget, class: string = "", container: bool = false, visual: string = "", colormap: string or Widget = "new", screen: string = "", use: string = ""): Toplevel =
  new result

  result.pathname = pathname(parent.pathname, genName("toplevel_"))
  result.tk = parent.tk

  discard result.tk.call(
    "toplevel",
    result.pathname,
    {"class": class, "container": $container, "visual": visual, "colormap": $colormap, "screen": screen, "use": use}.toArgs()
  )

#! menu

proc `background=`*(t: Toplevel or Root, background: Color or string) = t.configure({"background": $background & ' '})
proc `height=`*(t: Toplevel or Root, height: string or float or int) = t.configure({"height": $height})
proc `width=`*(t: Toplevel or Root, width: string or float or int) = t.configure({"width": $width})
proc `menu=`*(t: Toplevel or Root, menu: Menu) = t.configure({"menu": $menu})

proc background*(t: Toplevel or Root): Color = fromTclColor t, t.cget("background")
proc height*(t: Toplevel or Root): string = t.cget("height")
proc width*(t: Toplevel or Root): string = t.cget("width")
proc class*(t: Toplevel or Root): string = t.cget("class")
proc colormap*(t: Toplevel or Root): string = t.cget("colormap")
proc container*(t: Toplevel or Root): bool = t.cget("container") == "1"
proc screen*(t: Toplevel or Root): string = t.cget("screen")
proc use*(t: Toplevel or Root): Widget =
  let res = t.cget("use")

  if res.len == 0:
    return nil
  else:
    t.tk.newWidgetFromPathname t.tk.pathName(res)
proc visual*(t: Toplevel or Root): string = t.cget("visual")
proc menu*(t: Toplevel or Root): Menu =
  new result

  let pathname = t.cget("menu")

  result.tk = t.tk
  result.pathname = pathname

