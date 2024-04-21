import std/strutils

import ../../nimtk
import ./widget

type
  Button* = ref object of Widget

proc newButton*(parent: Widget, text: string = "", configuration: openArray[(string, string)] = {:}): Button =
  new result

  result.pathname = pathname(parent.pathname, genName("button_"))
  result.tk = parent.tk

  result.tk.call("button", result.pathname)

  if text.len > 0:
    result.configure({"text": repr text})
  
  if configuration.len > 0:
    result.configure(configuration)

proc invoke*(b: Button) = b.tk.call($b, "invoke")
proc flash*(b: Button) = b.tk.call($b, "flash")

proc setCommand*(b: Button, clientData: pointer, command: TkWidgetCommand) =
  let name = genName("button_command_")
  
  b.tk.registerCmd(b, clientdata, name, command)

  b.configure({"command": name})
proc `command=`*(b: Button, command: TkWidgetCommand) = b.setCommand(nil, command)
proc `default=`*(b: Button, default: WidgetState) = b.configure({"default": $default})
proc `height=`*(b: Button, height: string or float or int) = b.configure({"height": $height})
proc `overrelief=`*(b: Button, overrelief: WidgetRelief) = b.configure({"overrelief": $overrelief})
proc `state=`*(b: Button, state: WidgetState) = b.configure({"state": $state})
proc `width=`*(b: Button, width: string or float or int) = b.configure({"width": $width})

proc default*(b: Button): WidgetState = parseEnum[WidgetState] b.cget("default")
proc height*(b: Button): string = b.cget("height")
proc overrelief*(b: Button): WidgetRelief = parseEnum[WidgetRelief] b.cget("overrelief")
proc state*(b: Button): WidgetState = parseEnum[WidgetState] b.cget("state")
proc width*(b: Button): string = b.cget("width")
