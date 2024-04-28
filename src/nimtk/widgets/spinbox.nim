import std/sequtils
import std/strutils
import std/colors

import ../private/escaping
import ../private/tcllist
import ../private/alias
import ../../nimtk
import ./widget

type
  Spinbox* = ref object of Widget

  Index = string or int

proc isSpinbox*(w: Widget): bool = "spinbox" in w.pathname.split('.')[^1]

proc newSpinbox*(parent: Widget, values: openArray[string] = [], configuration: openArray[(string, string)] = {:}): Spinbox =
  new result

  result.pathname = pathname(parent.pathname, genName("spinbox_"))
  result.tk = parent.tk

  result.tk.call("spinbox", result.pathname)

  result.configure({"textvariable": genName("DEFAULTVAR_string_")})

  if values.len > 0:
    result.configure({"values": values.map(tclEscape).toTclList()})
  
  if configuration.len > 0:
    result.configure(configuration)

proc bbox*(s: Spinbox, index: Index): tuple[offsetX, offsetY, width, height: int] =
  s.tk.call($s, "bbox", index)

  if s.tk.result.len == 0:
    return
  
  let nums = s.tk.result.split()

  result.offsetX = nums[0].parseInt()
  result.offsetY = nums[1].parseInt()
  result.width = nums[2].parseInt()
  result.height = nums[3].parseInt()
proc delete*[I1, I2: Index](s: Spinbox, first: I1; last: I2 = "") = s.tk.call($s, "delete", first, last)
proc get*(s: Spinbox): string {.alias: "text".} = s.tk.call($s, "get")
proc icursor*(s: Spinbox, index: Index) = s.tk.call($s, "icursor", index)
proc identify*(s: Spinbox, x, y: int): string = s.tk.call($s, "identify", x, y) # TODO 
proc index*(s: Spinbox, index: string): int = parseInt s.tk.call($s, "index", index)
proc insert*(s: Spinbox, index: string, str: string): int = parseInt s.tk.call($s, "insert", index, tclEscape str)
proc invoke*(s: Spinbox, element: string) = s.tk.call($s, "invoke", element) # TODO `element` may be an enum
proc scanMark*(s: Spinbox, x: int) = s.tk.call($s, "scan mark", x)
proc scanDragTo*(s: Spinbox, x: int) = s.tk.call($s, "scan dragto", x)
proc selectionAdjust*(s: Spinbox, index: Index) = s.tk.call($s, "selection adjust", index)
proc selectionClear*(s: Spinbox) = s.tk.call($s, "selection clear")
proc selectionFrom*(s: Spinbox, index: Index) = s.tk.call($s, "selection from", index)
proc selectionPresent*(s: Spinbox): bool = s.tk.call($s, "selection present") == "1"
proc selectionRange*[I1, I2: Index](s: Spinbox, start: I1, `end`: I2) = s.tk.call($s, "selection range", start, `end`)
proc selectionTo*(s: Spinbox, index: Index) = s.tk.call($s, "selection to", index)
proc set*(s: Spinbox, text: string) {.alias: "text".} = s.tk.call($s, "set", tclEscape text)
proc validate*(s: Spinbox): bool = s.tk.call($s, "validate") == "1"
proc xview*(s: Spinbox): array[2, float] =
  s.tk.call($s, "xview")

  let res = s.tk.result.split(' ')

  result[0] = parseFloat res[0]
  result[1] = parseFloat res[1]
proc xview*(s: Spinbox, index: Index) = s.tk.call($s, "xview", index)
proc xviewMoveto*(s: Spinbox, fraction: 0.0..1.0) = s.tk.call($s, "xview moveto", fraction)
proc xviewScroll*(s: Spinbox, number: int, what: string) = s.tk.call($s, "xview scroll", number, tclEscape what)

proc setValidateCommand*(s: Spinbox, command: TkEntryCommand) =
  let name = genName("spinbox_validate_command_")
  s.tk.registerCmd(s, name, command)
  s.configure({"validatecommand": "{$1 %d %i %P %s %S %v %V}" % name})
proc setInvalidCommand*(s: Spinbox, command: TkEntryCommand) =
  let name = genName("spinbox_invalid_command_")
  s.tk.registerCmd(s, name, command)
  s.configure({"invalidcommand": "{$1 %d %i %P %s %S %v %V}" % name})
proc setCommand*(s: Spinbox, command: TkSpinboxCommand) =
  let name = genName("spinbox_command_")
  s.tk.registerCmd(s, name, command)
  s.configure({"command": "{$1 %d}" % name})

proc `validatecommand=`*(s: Spinbox, command: TkEntryCommand) = s.setValidateCommand(command)
proc `invalidcommand=`*(s: Spinbox, command: TkEntryCommand) = s.setInvalidCommand(command)
proc `buttonbackground=`*(s: Spinbox, buttonbackground: Color or string) = s.configure({"buttonbackground": tclEscape $buttonbackground})
proc `buttoncursor=`*(s: Spinbox, buttoncursor: Cursor or string) = s.configure({"buttoncursor": tclEscape $buttoncursor})
proc `buttondownrelief=`*(s: Spinbox, buttondownrelief: WidgetRelief) = s.configure({"buttondownrelief": $buttondownrelief})
proc `buttonuprelief=`*(s: Spinbox, buttonuprelief: WidgetRelief) = s.configure({"buttonuprelief": $buttonuprelief})
proc `command=`*(s: Spinbox, command: TkSpinboxCommand) = s.setCommand(command)
proc `disabledbackground=`*(s: Spinbox, disabledforeground: Color or string) = s.configure({"disabledbackground": tclEscape $disabledbackground})
proc `disabledforeground=`*(s: Spinbox, disabledforeground: Color or string) = s.configure({"disabledforeground": tclEscape $disabledforeground})
proc `format=`*(s: Spinbox, format: string) = s.configure({"format": tclEscape $format})
proc `from=`*(s: Spinbox, num: float) = s.configure({"from": $num})
proc `increment=`*(s: Spinbox, increment: float) = s.configure({"increment": $increment})
proc `readonlybackground=`*(s: Spinbox, readonlybackground: Color or string) = s.configure({"readonlybackground": tclEscape $readonlybackground})
proc `state=`*(s: Spinbox, state: WidgetState) = s.configure({"state": $state})
proc `to=`*(s: Spinbox, to: float) = s.configure({"to": $to})
proc `validationMode=`*(s: Spinbox, validationMode: ValidationMode) = s.configure({"validate": $validationMode})
proc `values=`*(s: Spinbox, values: openArray[string]) = s.configure({"values": values.map(tclEscape).toTclList()})
proc `width=`*(s: Spinbox, width: int) = s.configure({"width": $width})
proc `wrap=`*(s: Spinbox, wrap: bool) = s.configure({"wrap": $wrap})

proc buttonbackground*(s: Spinbox): Color = fromTclColor s, s.cget("buttonbackground")
proc buttoncursor*(s: Spinbox): Cursor = parseEnum[Cursor] s.cget("buttoncursor")
proc buttondownrelief*(s: Spinbox): WidgetRelief = parseEnum[WidgetRelief] s.cget("buttondownrelief")
proc buttonuprelief*(s: Spinbox): WidgetRelief = parseEnum[WidgetRelief] s.cget("buttonuprelief")
proc disabledbackground*(s: Spinbox): Color = fromTclColor s, s.cget("disabledbackground")
proc disabledforeground*(s: Spinbox): Color = fromTclColor s, s.cget("disabledforeground")
proc format*(s: Spinbox): string = s.cget("format")
proc `from`*(s: Spinbox): float = parseFloat s.cget("from")
proc increment*(s: Spinbox): float = parseFloat s.cget("increment")
proc readonlybackground*(s: Spinbox): Color = fromTclColor s, s.cget("readonlybackground")
proc state*(s: Spinbox): WidgetState = parseEnum[WidgetState] s.cget("state")
proc to*(s: Spinbox): float = parseFloat s.cget("to")
proc validationMode*(s: Spinbox): ValidationMode = parseEnum[ValidationMode] s.cget("validate")
proc values*(s: Spinbox): seq[string] = s.cget("values").split(' ')
proc width*(s: Spinbox): int = parseInt s.cget("width")
proc wrap*(s: Spinbox): bool = s.cget("wrap") == "1"
