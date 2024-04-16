import std/strutils

import ./widget
import ../nimtk

type
  Button* = ref object of Widget
    # command: TkCommand

  ButtonState* = enum
    Normal = "normal"
    Active = "active"
    Disabled = "disabled"

proc newButton*(parent: Widget, text: string = "", configuration: openArray[(string, string)] = {:}): Button =
  new result

  result.pathname = pathname(parent.pathname, genName())
  result.tk = parent.tk

  result.tk.call("button", result.pathname)

  result.configure({"text": text})
  result.configure(configuration)

proc invoke*(b: Button) = b.tk.call($b, "invoke")
proc flash*(b: Button) = b.tk.call($b, "flash")

template setCommand*(b: Button, clientData: pointer, command: TkCommand) =
  let name = genName()
  b.tk.registerCmd(b, clientdata, name, command)

  b.configure({"command": name})
template `command=`*(b: Button, command: TkCommand) = b.setCommand(nil, command)
proc `default=`*(b: Button, default: ButtonState) = b.configure({"default": $default})
proc `height=`*(b: Button, height: string or float or int) = b.configure({"height": $height})
proc `overrelief=`*(b: Button, overrelief: WidgetRelief) = b.configure({"overrelief": $overrelief})
proc `state=`*(b: Button, state: ButtonState) = b.configure({"state": $state})
proc `width=`*(b: Button, width: string or float or int) = b.configure({"width": $width})

proc default*(b: Button): ButtonState = parseEnum[ButtonState] b.cget("default")
proc height*(b: Button): string = b.cget("height")
proc overrelief*(b: Button): WidgetRelief = parseEnum[WidgetRelief] b.cget("overrelief")
proc state*(b: Button): ButtonState = parseEnum[ButtonState] b.cget("state")
proc width*(b: Button): string = b.cget("width")
