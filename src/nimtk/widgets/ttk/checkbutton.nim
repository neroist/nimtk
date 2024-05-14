import std/strutils

import ../../utils/escaping
import ../../utils/genname
import ../../utils/toargs
import ../../variables
import ../../../nimtk
import ../widget
import ./widget

type
  TtkCheckButton* = ref object of TtkWidget

proc isTtkCheckButton*(w: Widget): bool = "ttkcheckbutton" in w.pathname.split('.')[^1]

proc newTtkCheckButton*(parent: Widget, text: string = "", configuration: openArray[(string, string)] = {:}): TtkCheckButton =
  new result

  result.pathname = pathname(parent.pathname, genName("ttkcheckbutton_"))
  result.tk = parent.tk

  result.tk.call("ttk::checkbutton", result.pathname)
    
  if text.len > 0:
    result.configure({"text": tclEscape text})

  if configuration.len > 0:
    result.configure(configuration)

proc invoke*(c: TtkCheckButton) = c.tk.call($c, "invoke")

proc setCommand*(c: TtkCheckButton, command: TkWidgetCommand) =
  let name = genName("ttkcheckbutton_command_")
  
  c.tk.registerCmd(c, name, command)

  c.configure({"command": name})
proc `command=`*(c: TtkCheckButton, command: TkWidgetCommand) = c.setCommand(command)
proc `variable=`*(c: TtkCheckButton, variable: TkBool) = c.configure({"variable": variable.varname})
proc `offvalue=`*(c: TtkCheckButton, offvalue: string) = c.configure({"offvalue": tclEscape offvalue})
proc `onvalue=`*(c: TtkCheckButton, onvalue: string) = c.configure({"onvalue": tclEscape onvalue})

proc variable*(c: TtkCheckButton): TkBool = createTkVar c.tk, c.cget("variable")
proc offvalue*(c: TtkCheckButton): string = c.cget("offvalue")
proc onvalue*(c: TtkCheckButton): string = c.cget("onvalue")
