import std/strutils
import std/colors
import std/macros

import ../../nimtk
import ./button
import ./widget

type
  CheckButton* = ref object of Widget

proc newCheckButton*(parent: Widget, text: string = "", configuration: openArray[(string, string)] = {:}): CheckButton =
  new result

  result.pathname = pathname(parent.pathname, genName("checkbutton_"))
  result.tk = parent.tk

  result.tk.call("checkbutton", result.pathname)

  result.configure({"text": text})
  result.configure(configuration)

proc invoke*(c: CheckButton) = c.tk.call($c, "invoke")
proc flash*(c: CheckButton) = c.tk.call($c, "flash")
proc select*(c: CheckButton) = c.tk.call($c, "select")
proc toggle*(c: CheckButton) = c.tk.call($c, "toggle")
proc deselect*(c: CheckButton) = c.tk.call($c, "deselect")

proc setCommand*(c: CheckButton, clientData: pointer, command: TkCommand) =
  let name = genName("checkbutton_command_")
  
  c.tk.registerCmd(c, clientdata, name, command)

  c.configure({"command": name})
proc `command=`*(c: CheckButton, command: TkCommand) = c.setCommand(nil, command)
proc `default=`*(c: CheckButton, default: ButtonState) = c.configure({"default": $default})
proc `indicatoron=`*(c: CheckButton, indicatoron: bool) = c.configure({"indicatoron": $indicatoron})
proc `height=`*(c: CheckButton, height: string or float or int) = c.configure({"height": $height})
proc `offrelief=`*(c: CheckButton, offrelief: WidgetRelief) = c.configure({"offrelief": $offrelief})
proc `overrelief=`*(c: CheckButton, overrelief: WidgetRelief) = c.configure({"overrelief": $overrelief})
proc `selectcolor=`*(c: CheckButton, selectcolor: Color) = c.configure({"selectcolor": $selectcolor})
proc `variable=`*(c: CheckButton, variable: TkBool) = c.configure({"variable": $variable})
# proc `selectimage=`*(c: CheckButton, selectimage: Image) = c.configure({"selectimage": $selectimage})
# proc `tristateimage=`*(c: CheckButton, tristateimage: Image) = c.configure({"tristateimage": $tristateimage})
proc `state=`*(c: CheckButton, state: ButtonState) = c.configure({"state": $state})
proc `width=`*(c: CheckButton, width: string or float or int) = c.configure({"width": $width})

proc default*(c: CheckButton): ButtonState = parseEnum[ButtonState] c.cget("default")
proc indicatoron*(c: CheckButton): bool = c.cget("indicatoron") == "1"
proc height*(c: CheckButton): string = c.cget("height")
proc offrelief*(c: CheckButton): WidgetRelief = parseEnum[WidgetRelief] c.cget("offrelief")
proc overrelief*(c: CheckButton): WidgetRelief = parseEnum[WidgetRelief] c.cget("overrelief")
proc selectcolor*(c: CheckButton): Color = parseColor c.cget("selectcolor")
proc variable*(c: CheckButton): TkBool =
  let name = c.cget("variable")
  
  if name.len == 0:
    return nil

  new result

  result.varname = name
  result.tk = c.tk
proc state*(c: CheckButton): ButtonState = parseEnum[ButtonState] c.cget("state")
proc width*(c: CheckButton): string = c.cget("width")