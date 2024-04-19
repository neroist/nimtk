import std/strutils
import std/colors
import std/macros

import ../../nimtk
import ./widget

type
  RadioButton* = ref object of Widget

proc newRadioButton*(parent: Widget, text: string = "", configuration: openArray[(string, string)] = {:}): RadioButton =
  new result

  result.pathname = pathname(parent.pathname, genName("radiobutton_"))
  result.tk = parent.tk

  result.tk.call("radiobutton", result.pathname)

  result.configure({"text": text})
  result.configure(configuration)

proc invoke*(r: RadioButton) = r.tk.call($c, "invoke")
proc flash*(r: RadioButton) = r.tk.call($c, "flash")
proc select*(r: RadioButton) = r.tk.call($c, "select")
proc toggle*(r: RadioButton) = r.tk.call($c, "toggle")
proc deselect*(r: RadioButton) = r.tk.call($c, "deselect")

proc setCommand*(r: RadioButton, clientData: pointer, command: TkWidgetCommand) =
  let name = genName("checkbutton_command_")
  
  r.tk.registerCmd(r, clientdata, name, command)

  r.configure({"command": name})
proc `command=`*(r: RadioButton, command: TkWidgetCommand) = r.setCommand(nil, command)
proc `default=`*(r: RadioButton, default: WidgetState) = r.configure({"default": $default})
proc `indicatoron=`*(r: RadioButton, indicatoron: bool) = r.configure({"indicatoron": $indicatoron})
proc `height=`*(r: RadioButton, height: string or float or int) = r.configure({"height": $height})
proc `offrelief=`*(r: RadioButton, offrelief: WidgetRelief) = r.configure({"offrelief": $offrelief})
proc `overrelief=`*(r: RadioButton, overrelief: WidgetRelief) = r.configure({"overrelief": $overrelief})
proc `selectcolor=`*(r: RadioButton, selectcolor: Color) = r.configure({"selectcolor": $selectcolor})
proc `variable=`*(r: RadioButton, variable: TkBool) = r.configure({"variable": $variable})
# proc `selectimage=`*(r: RadioButton, selectimage: Image) = r.configure({"selectimage": $selectimage})
# proc `tristateimage=`*(r: RadioButton, tristateimage: Image) = r.configure({"tristateimage": $tristateimage})
proc `state=`*(r: RadioButton, state: WidgetState) = r.configure({"state": $state})
proc `width=`*(r: RadioButton, width: string or float or int) = r.configure({"width": $width})

proc default*(r: RadioButton): WidgetState = parseEnum[WidgetState] c.cget("default")
proc indicatoron*(r: RadioButton): bool = c.cget("indicatoron") == "1"
proc height*(r: RadioButton): string = c.cget("height")
proc offrelief*(r: RadioButton): WidgetRelief = parseEnum[WidgetRelief] c.cget("offrelief")
proc overrelief*(r: RadioButton): WidgetRelief = parseEnum[WidgetRelief] c.cget("overrelief")
proc selectcolor*(r: RadioButton): Color = parseColor c.cget("selectcolor")
proc variable*(r: RadioButton): TkBool = createTkVar r.tk, c.cget("variable")
proc state*(r: RadioButton): WidgetState = parseEnum[WidgetState] c.cget("state")
proc width*(r: RadioButton): string = c.cget("width")
