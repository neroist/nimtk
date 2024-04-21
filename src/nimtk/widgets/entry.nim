import std/strutils

import ../../nimtk
import ./widget

type
  Entry* = ref object of Widget

proc newButton*(parent: Widget, text: string = "", configuration: openArray[(string, string)] = {:}): Entry =
  new result

  result.pathname = pathname(parent.pathname, genName("entry_"))
  result.tk = parent.tk

  result.tk.call("entry", result.pathname)

  if text.len > 0:
    result.configure({"text": repr text})
  
  if configuration.len > 0:
    result.configure(configuration)

proc invoke*(e: Entry) = e.tk.call($e, "invoke")
proc flash*(e: Entry) = e.tk.call($e, "flash")

proc setCommand*(e: Entry, clientData: pointer, command: TkWidgetCommand) =
  let name = genName("button_command_")
  
  e.tk.registerCmd(e, clientdata, name, command)

  e.configure({"command": name})
proc `command=`*(e: Entry, command: TkWidgetCommand) = e.setCommand(nil, command)
proc `default=`*(e: Entry, default: WidgetState) = e.configure({"default": $default})
proc `height=`*(e: Entry, height: string or float or int) = e.configure({"height": $height})
proc `overrelief=`*(e: Entry, overrelief: WidgetRelief) = e.configure({"overrelief": $overrelief})
proc `state=`*(e: Entry, state: WidgetState) = e.configure({"state": $state})
proc `width=`*(e: Entry, width: string or float or int) = e.configure({"width": $width})

proc default*(e: Entry): WidgetState = parseEnum[WidgetState] e.cget("default")
proc height*(e: Entry): string = e.cget("height")
proc overrelief*(e: Entry): WidgetRelief = parseEnum[WidgetRelief] e.cget("overrelief")
proc state*(e: Entry): WidgetState = parseEnum[WidgetState] e.cget("state")
proc width*(e: Entry): string = e.cget("width")
