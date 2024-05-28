import std/strutils

import ../../utils/escaping
import ../../utils/genname
import ../../utils/toargs
import ../../variables
import ../../../nimtk
import ../widget
import ./widget

type
  TtkRadioButton* = ref object of TtkWidget

proc isTtkRadioButton*(w: Widget): bool = "ttkradiobutton" in w.pathname.split('.')[^1]

proc newTtkRadioButton*(parent: Widget, text: string = "", configuration: openArray[(string, string)] = {:}): TtkRadioButton =
  new result

  result.pathname = pathname(parent.pathname, genName("ttkradiobutton_"))
  result.tk = parent.tk

  result.tk.call("ttk::radiobutton", result.pathname)
    
  if text.len > 0:
    result.configure({"text": tclEscape text})

  if configuration.len > 0:
    result.configure(configuration)

proc invoke*(r: TtkRadioButton) = r.call("invoke")

proc setCommand*(r: TtkRadioButton, command: TkWidgetCommand) =
  let name = genName("ttkradiobutton_command_")
  
  r.tk.registerCmd(r, name, command)

  r.configure({"command": name})
proc `command=`*(r: TtkRadioButton, command: TkWidgetCommand) = r.setCommand(command)
proc `variable=`*(r: TtkRadioButton, variable: TkString) = r.configure({"variable": variable.varname})
proc `value=`*(r: TtkRadioButton, value: string) = r.configure({"value": tclEscape value})

proc variable*(r: TtkRadioButton): TkString = createTkVar r.tk, r.cget("variable")
proc value*(r: TtkRadioButton): string = r.cget("value")
