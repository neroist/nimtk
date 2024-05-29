import std/strutils
import std/colors

import ../utils/tclcolor
import ../utils/escaping
import ../utils/genname
import ../utils/toargs
import ../variables
import ../../nimtk
import ../images
import ./widget

type
  RadioButton* = ref object of Widget

proc isRadioButton*(w: Widget): bool = "radiobutton" in w.pathname.split('.')[^1]

proc newRadioButton*(parent: Widget, text: string = "", configuration: openArray[(string, string)] = {:}): RadioButton =
  new result

  result.pathname = pathname(parent.pathname, genName("radiobutton_"))
  result.tk = parent.tk

  result.tk.call("radiobutton", result.pathname, {"text": tclEscape text}.toArgs)

  if configuration.len > 0:
    result.configure(configuration)

proc invoke*(r: RadioButton) = r.call("invoke")
proc flash*(r: RadioButton) = r.call("flash")
proc select*(r: RadioButton) = r.call("select")
proc toggle*(r: RadioButton) = r.call("toggle")
proc deselect*(r: RadioButton) = r.call("deselect")

proc setCommand*(r: RadioButton, command: TkWidgetCommand) =
  let name = genName("checkbutton_command_")
  
  r.tk.registerCmd(r, name, command)

  r.configure({"command": name})
proc `command=`*(r: RadioButton, command: TkWidgetCommand) = r.setCommand(command)
proc `indicatoron=`*(r: RadioButton, indicatoron: bool) = r.configure({"indicatoron": $indicatoron})
proc `height=`*(r: RadioButton, height: string or float or int) = r.configure({"height": $height})
proc `offrelief=`*(r: RadioButton, offrelief: WidgetRelief) = r.configure({"offrelief": $offrelief})
proc `overrelief=`*(r: RadioButton, overrelief: WidgetRelief) = r.configure({"overrelief": $overrelief})
proc `selectcolor=`*(r: RadioButton, selectcolor: Color) = r.configure({"selectcolor": $selectcolor})
proc `variable=`*(r: RadioButton, variable: TkVar) = r.configure({"variable": variable.varname})
proc `value=`*(r: RadioButton, value: bool or int or string) = r.configure({"value":  tclEscape value})
proc `tristatevalue=`*(r: RadioButton, tristatevalue: string) = r.configure({"tristatevalue":  tclEscape tristatevalue})
proc `selectimage=`*(r: RadioButton, selectimage: Image) = r.configure({"selectimage": $selectimage})
proc `tristateimage=`*(r: RadioButton, tristateimage: Image) = r.configure({"tristateimage": $tristateimage})
proc `state=`*(r: RadioButton, state: WidgetState) = r.configure({"state": $state})
proc `width=`*(r: RadioButton, width: string or float or int) = r.configure({"width": $width})

proc indicatoron*(r: RadioButton): bool = r.cget("indicatoron") == "1"
proc height*(r: RadioButton): string = r.cget("height")
proc offrelief*(r: RadioButton): WidgetRelief = parseEnum[WidgetRelief] r.cget("offrelief")
proc overrelief*(r: RadioButton): WidgetRelief = parseEnum[WidgetRelief] r.cget("overrelief")
proc selectcolor*(r: RadioButton): Color = fromTclColor r, r.cget("selectcolor")
proc variable*(r: RadioButton): TkVar = createTkVar r.tk, r.cget("variable")
proc value*(r: RadioButton): string = r.cget("value")
proc tristatevalue*(r: RadioButton): string = r.cget("tristatevalue")
proc state*(r: RadioButton): WidgetState = parseEnum[WidgetState] r.cget("state")
proc width*(r: RadioButton): string = r.cget("width")
