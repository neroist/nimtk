import std/strutils

import ../../utils/escaping
import ../../utils/genname
import ../../utils/toargs
import ../../../nimtk
import ../widget
import ./widget

type
  TtkButton* = ref object of TtkWidget

proc isTtkButton*(w: Widget): bool = "ttkbutton" in w.pathname.split('.')[^1]

proc newTtkButton*(parent: Widget, text: string = "", configuration: openArray[(string, string)] = {:}): TtkButton =
  new result

  result.pathname = pathname(parent.pathname, genName("ttkbutton_"))
  result.tk = parent.tk

  result.tk.call("ttk::button", result.pathname, {"text": tclEscape text}.toArgs())
  
  if configuration.len > 0:
    result.configure(configuration)

proc invoke*(b: TtkButton) = b.call("invoke")

proc setCommand*(b: TtkButton, command: TkWidgetCommand) =
  let name = genName("ttkbutton_command_")
  
  b.tk.registerCmd(b, name, command)

  b.configure({"command": name})
proc `command=`*(b: TtkButton, command: TkWidgetCommand) = b.setCommand(command)
proc `default=`*(b: TtkButton, default: WidgetState) = b.configure({"default": $default})

proc default*(b: TtkButton): WidgetState = parseEnum[WidgetState] b.cget("default")
