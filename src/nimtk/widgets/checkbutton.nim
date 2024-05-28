import std/strutils
import std/colors
import std/macros

import ../utils/escaping
import ../utils/tclcolor
import ../utils/genname
import ../variables
import ../../nimtk
import ../images
import ./widget

type
  CheckButton* = ref object of Widget

proc isCheckButton*(w: Widget): bool = "checkbutton" in w.pathname.split('.')[^1]

proc newCheckButton*(parent: Widget, text: string = "", configuration: openArray[(string, string)] = {:}): CheckButton =
  new result

  result.pathname = pathname(parent.pathname, genName("checkbutton_"))
  result.tk = parent.tk

  result.tk.call("checkbutton", result.pathname)
    
  if text.len > 0:
    result.configure({"text": tclEscape text})

  if configuration.len > 0:
    result.configure(configuration)

proc invoke*(c: CheckButton) = c.call("invoke")
proc flash*(c: CheckButton) = c.call("flash")
proc select*(c: CheckButton) = c.call("select")
proc toggle*(c: CheckButton) = c.call("toggle")
proc deselect*(c: CheckButton) = c.call("deselect")
proc get*(c: CheckButton): bool = c.tk.call("set", c.cget("variable")) == "1"
proc set*(c: CheckButton, state: bool) = c.tk.call("set", c.cget("variable"), $int(state))

proc setCommand*(c: CheckButton, command: TkWidgetCommand) =
  let name = genName("checkbutton_command_")
  
  c.tk.registerCmd(c, name, command)

  c.configure({"command": name})
proc `command=`*(c: CheckButton, command: TkWidgetCommand) = c.setCommand(command)
proc `indicatoron=`*(c: CheckButton, indicatoron: bool) = c.configure({"indicatoron": $indicatoron})
proc `height=`*(c: CheckButton, height: string or float or int) = c.configure({"height": $height})
proc `offrelief=`*(c: CheckButton, offrelief: WidgetRelief) = c.configure({"offrelief": $offrelief})
proc `overrelief=`*(c: CheckButton, overrelief: WidgetRelief) = c.configure({"overrelief": $overrelief})
proc `selectcolor=`*(c: CheckButton, selectcolor: Color) = c.configure({"selectcolor": $selectcolor})
proc `variable=`*(c: CheckButton, variable: TkBool) = c.configure({"variable": variable.varname})
proc `selectimage=`*(c: CheckButton, selectimage: Image) = c.configure({"selectimage": $selectimage})
proc `tristateimage=`*(c: CheckButton, tristateimage: Image) = c.configure({"tristateimage": $tristateimage})
proc `state=`*(c: CheckButton, state: WidgetState) = c.configure({"state": $state})
proc `tristatevalue=`*(c: CheckButton, tristatevalue: string) = c.configure({"tristatevalue":  tclEscape tristatevalue})
proc `width=`*(c: CheckButton, width: string or float or int) = c.configure({"width": $width})

proc indicatoron*(c: CheckButton): bool = c.cget("indicatoron") == "1"
proc height*(c: CheckButton): string = c.cget("height")
proc offrelief*(c: CheckButton): WidgetRelief = parseEnum[WidgetRelief] c.cget("offrelief")
proc overrelief*(c: CheckButton): WidgetRelief = parseEnum[WidgetRelief] c.cget("overrelief")
proc selectcolor*(c: CheckButton): Color = fromTclColor c, c.cget("selectcolor")
proc variable*(c: CheckButton): TkBool = createTkVar c.tk, c.cget("variable")
proc state*(c: CheckButton): WidgetState = parseEnum[WidgetState] c.cget("state")
proc tristatevalue*(c: CheckButton): string = c.cget("tristatevalue")
proc width*(c: CheckButton): string = c.cget("width")
