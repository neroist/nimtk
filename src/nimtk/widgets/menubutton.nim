import std/sequtils
import std/strutils

import ../utils/escaping
import ../utils/genname
import ../utils/toargs
import ../variables
import ../../nimtk
import ./widget
import ./menu

type
  MenuButton* = ref object of Widget

proc isMenuButton*(w: Widget): bool = "menubutton" in w.pathname.split('.')[^1]

proc newMenuButton*(parent: Widget, text: string = "", configuration: openArray[(string, string)] = {:}): MenuButton =
  new result

  result.pathname = pathname(parent.pathname, genName("menubutton_"))
  result.tk = parent.tk

  result.tk.call("menubutton", result.pathname, {"text": tclEscape text}.toArgs)
  
  if configuration.len > 0:
    result.configure(configuration)

proc newOptionMenu*(parent: Widget, variable: TkVar, values: varargs[string, `$`], configuration: openArray[(string, string)] = {:}): MenuButton =
  new result

  result.pathname = pathname(parent.pathname, genName("menubutton_"))
  result.tk = parent.tk

  result.tk.call("tk_optionMenu", result.pathname, variable.varname, values.map(tclEscape).join(" "))
  
  if configuration.len > 0:
    result.configure(configuration)

proc `direction=`*(m: MenuButton, direction: MenuButtonDirection) = m.configure({"direction": $direction})
proc `height=`*(m: MenuButton, height: int) = m.configure({"height": $height})
proc `indicatoron=`*(m: MenuButton, indicatoron: bool) = m.configure({"indicatoron": $indicatoron})
proc `menu=`*(m: MenuButton, menu: Menu) = m.configure({"menu": $menu})
proc `state=`*(m: MenuButton, state: WidgetState) = m.configure({"state": $state})
proc `width=`*(m: MenuButton, width: int) = m.configure({"width": $width})

proc direction*(m: MenuButton): MenuButtonDirection = parseEnum[MenuButtonDirection] m.cget("direction")
proc height*(m: MenuButton): int = parseInt m.cget("height")
proc indicatoron*(m: MenuButton): bool = m.cget("indicatoron") == "1"
proc menu*(m: MenuButton): Menu = 
  new result

  result.tk = m.tk
  result.pathname = m.cget("menu")
proc state*(m: MenuButton): WidgetState = parseEnum[WidgetState] m.cget("state")
proc width*(m: MenuButton): int = parseInt m.cget("width")
