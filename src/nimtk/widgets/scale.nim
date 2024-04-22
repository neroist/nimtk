import std/strutils

import ../private/escaping
import ../private/alias
import ../../nimtk
import ./widget

type
  Scale* = ref object of Widget

proc newScale*(parent: Widget, fromto: Slice[int or float], configuration: openArray[(string, string)] = {:}): Scale =
  new result

  result.pathname = pathname(parent.pathname, genName("scale_"))
  result.tk = parent.tk

  result.tk.call("scale", result.pathname)

  result.configure({"from": $fromto.a, "to": $fromto.b})

  if configuration.len > 0:
    result.configure(configuration)

proc coords*(s: Scale, value: int or float): tuple[x, y: int] = 
  s.tk.call($s, "coords", value)

  let res = s.tk.result.split(" ")

  result.x = res[0].parseInt()
  result.y = res[1].parseInt()

proc coords*(s: Scale): tuple[x, y: int] = 
  s.tk.call($s, "coords")

  let res = s.tk.result.split(" ")

  result.x = res[0].parseInt()
  result.y = res[1].parseInt()

proc get*(s: Scale, x, y: int): float =
  s.tk.call($s, "get", x, y).parseFloat()

proc get*(s: Scale): float =
  s.tk.call($s, "get").parseFloat()

proc identify*(s: Scale, x, y: int): string =
  s.tk.call($s, "idenify", x, y)

proc set*(s: Scale, value: int or float) {.alias: "value=".} =
  s.tk.call($s, "set", value)

proc setCommand*(s: Scale, clientData: pointer, command: TkScaleCommand) =
  let name = genName("scale_command_")
  
  s.tk.registerCmd(s, clientdata, name, command)

  s.configure({"command": name})
proc `command=`*(s: Scale, command: TkScaleCommand) = s.setCommand(nil, command)

proc `bigincrement=`*(s: Scale, bigincrement: int or float)           = s.configure({"bigincrement": $bigincrement})
proc `digits=`*(s: Scale, digits: int)                                = s.configure({"digits": $digits})
proc `from=`*(s: Scale, `from`: int or float)                         = s.configure({"from": $`from`})
proc `label=`*(s: Scale, label: string)                               = s.configure({"label": $label})
proc `length=`*(s: Scale, length: string or float or int)             = s.configure({"length": $length})
proc `resolution=`*(s: Scale, resolution: int or float)               = s.configure({"resolution": $resolution})
proc `showvalue=`*(s: Scale, showvalue: bool)                         = s.configure({"showvalue": $showvalue})
proc `sliderlength=`*(s: Scale, sliderlength: string or float or int) = s.configure({"sliderlength": $sliderlength})
proc `sliderrelief=`*(s: Scale, sliderrelief: WidgetRelief)           = s.configure({"sliderrelief": $sliderrelief})
proc `state=`*(s: Scale, state: WidgetState)                          = s.configure({"state": $state})
proc `tickinterval=`*(s: Scale, tickinterval: int or float)           = s.configure({"tickinterval": $tickinterval})
proc `to=`*(s: Scale, to: int or float)                               = s.configure({"to": $to})
proc `variable=`*(s: Scale, variable: TkVar)                          = s.configure({"variable": variable.varname})
proc `width=`*(s: Scale, width: string or float or int)               = s.configure({"width": $width})

proc bigincrement*(s: Scale): float        = parseFloat s.cget("bigincrement")
proc digits*(s: Scale): int                = parseInt s.cget("digits")
proc `from`*(s: Scale): float              = parseFloat s.cget("from")
proc label*(s: Scale): string              = s.cget("label")
proc length*(s: Scale): string             = s.cget("length")
proc resolution*(s: Scale): float          = parseFloat s.cget("resolution")
proc showvalue*(s: Scale): bool            = s.cget("showvalue") == "1"
proc sliderlength*(s: Scale): string       = s.cget("sliderlength")
proc sliderrelief*(s: Scale): WidgetRelief = parseEnum[WidgetRelief] s.cget("sliderrelief")
proc state*(s: Scale): WidgetState         = parseEnum[WidgetState] s.cget("state")
proc tickinterval*(s: Scale): float        = parseFloat s.cget("tickinterval")
proc to*(s: Scale): float                  = parseFloat s.cget("to")
proc variable*(s: Scale): Tkvar            = createTkVar s.tk, s.cget("variable")
proc width*(s: Scale): string              = s.cget("width")
