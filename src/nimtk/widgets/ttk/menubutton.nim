import std/strutils

import ../../utils/escaping
import ../../utils/genname
import ../../utils/toargs
import ../../../nimtk
import ../widget
import ./widget
import ../menu

type
  TtkMenuButton* = ref object of TtkWidget

proc isTtkMenuButton*(w: Widget): bool = "ttkmenubutton" in w.pathname.split('.')[^1]

proc newTtkMenuButton*(parent: Widget, text: string = "", configuration: openArray[(string, string)] = {:}): TtkMenuButton =
  new result

  result.pathname = pathname(parent.pathname, genName("ttkmenubutton_"))
  result.tk = parent.tk

  result.tk.call("ttk::menubutton", result.pathname, {"text": tclEscape text}.toArgs)
  
  if configuration.len > 0:
    result.configure(configuration)

proc `direction=`*(m: TtkMenuButton, direction: MenuButtonDirection) = m.configure({"direction": $direction})
proc `menu=`*(m: TtkMenuButton, menu: Menu) = m.configure({"menu": $menu})

proc direction*(m: TtkMenuButton): MenuButtonDirection = parseEnum[MenuButtonDirection] m.cget("direction")
proc menu*(m: TtkMenuButton): Menu = 
  new result

  result.tk = m.tk
  result.pathname = m.cget("menu")
