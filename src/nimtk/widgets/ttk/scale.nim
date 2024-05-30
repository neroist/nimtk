import std/strutils

import ../../utils/escaping
import ../../utils/genname
import ../../utils/toargs
import ../../variables
import ../../../nimtk
import ../widget
import ./widget

type
  TtkScale* = ref object of TtkWidget

proc isTtkScale*(w: Widget): bool = "ttkscale" in w.pathname.split('.')[^1]

proc newTtkScale*(parent: Widget, fromto: Slice[int or float], configuration: openArray[(string, string)] = {:}): TtkScale =
  new result

  result.pathname = pathname(parent.pathname, genName("ttkscale_"))
  result.tk = parent.tk

  result.tk.call("ttk::scale", result.pathname, {"from": $fromto.a, "to": $fromto.b}.toArgs)

  if configuration.len > 0:
    result.configure(configuration)

proc coords*(s: TtkScale, value: int or float): tuple[x, y: int] = 
  s.call("coords", value)

  let res = s.tk.result.split(' ')

  result.x = res[0].parseInt()
  result.y = res[1].parseInt()
proc coords*(s: TtkScale): tuple[x, y: int] = 
  s.call("coords")

  let res = s.tk.result.split(' ')

  result.x = res[0].parseInt()
  result.y = res[1].parseInt()
proc get*(s: TtkScale, x, y: int): float =
  s.call("get", x, y).parseFloat()
proc get*(s: TtkScale): float =
  s.call("get").parseFloat()
proc identify*(s: TtkScale, x, y: int): string =
  s.call("idenify", x, y)
proc set*(s: TtkScale, value: int or float) =
  s.call("set", value)

proc setCommand*(s: TtkScale, command: TkScaleCommand) =
  let name = genName("ttkscale_command_")
  
  s.tk.registerCmd(s, name, command)

  s.configure({"command": name})
proc `command=`*(s: TtkScale, command: TkScaleCommand) = s.setCommand(command)
proc `from=`*(s: TtkScale, `from`: int or float)                         = s.configure({"from": $`from`})
proc `length=`*(s: TtkScale, length: string or float or int)             = s.configure({"length": $length})
proc `to=`*(s: TtkScale, to: int or float)                               = s.configure({"to": $to})
proc `variable=`*(s: TtkScale, variable: TkVar)                          = s.configure({"variable": variable.varname})
proc `value=`*(s: TtkScale, value: float)                                = s.configure({"value": $value})

proc `from`*(s: TtkScale): float              = parseFloat s.cget("from")
proc length*(s: TtkScale): string             = s.cget("length")
proc to*(s: TtkScale): float                  = parseFloat s.cget("to")
proc variable*(s: TtkScale): Tkvar            = createTkVar s.tk, s.cget("variable")
proc width*(s: TtkScale): string              = s.cget("width")
