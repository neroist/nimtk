import std/strutils
import std/colors

import ../private/escaping
import ../private/alias
import ../../nimtk
import ./widget

type
  Spinbox* = ref object of Widget

  Index = string or int

proc newSpinbox*(parent: Widget, text: string = "", configuration: openArray[(string, string)] = {:}): Spinbox =
  new result

  result.pathname = pathname(parent.pathname, genName("spinbox_"))
  result.tk = parent.tk

  result.tk.call("spinbox", result.pathname)

  result.configure({"textvariable": genName("DEFAULTVAR_string_")})

  if text.len > 0:
    result.tk.call("set", result.cget("textvariable"), tclEscape text)
  
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

proc setValidateCommand*(s: Spinbox, clientData: pointer, command: TkEntryCommand) =
  let name = genName("entry_validate_command_")
  s.tk.registerCmd(s, clientdata, name, command)
  s.configure({"validatecommand": "{$1 %d %i %P %s %S %v %V}" % name})
proc setInvalidCommand*(s: Spinbox, clientData: pointer, command: TkEntryCommand) =
  let name = genName("entry_invalid_command_")
  s.tk.registerCmd(s, clientdata, name, command)
  s.configure({"invalidcommand": "{$1 %d %i %P %s %S %v %V}" % name})

proc `validatecommand=`*(s: Spinbox, command: TkEntryCommand) = s.setValidateCommand(nil, command)
proc `invalidcommand=`*(s: Spinbox, command: TkEntryCommand) = s.setInvalidCommand(nil, command)
proc `disabledbackground=`*(w: Widget, disabledforeground: Color or string) = w.configure({"disabledbackground": tclEscape $disabledbackground})
proc `readonlybackground=`*(w: Widget, readonlybackground: Color or string) = w.configure({"readonlybackground": tclEscape $readonlybackground})
proc `show=`*(w: Widget, show: char) = w.configure({"show": tclEscape $show})
proc `state=`*(s: Spinbox, state: WidgetState) = s.configure({"state": $state})
proc `validationMode=`*(s: Spinbox, validationMode: ValidationMode) = s.configure({"validate": $validationMode})
proc `width=`*(s: Spinbox, width: int) = s.configure({"width": $width})

proc disabledbackground*(w: Widget): Color = parseColor w.cget("disabledbackground")
proc readonlybackground*(w: Widget): Color = parseColor w.cget("readonlybackground")
proc show*(w: Widget): char = w.cget("show")[0]
proc state*(s: Spinbox): WidgetState = parseEnum[WidgetState] s.cget("state")
proc overrelief*(s: Spinbox): WidgetRelief = parseEnum[WidgetRelief] s.cget("overrelief")
proc validationMode*(s: Spinbox): ValidationMode = parseEnum[ValidationMode] s.cget("validate")
proc width*(s: Spinbox): int = parseInt s.cget("width")
