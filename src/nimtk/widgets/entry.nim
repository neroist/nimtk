import std/strutils
import std/colors

import ../utils/escaping
import ../utils/tclcolor
import ../utils/genname
import ../utils/alias
import ../../nimtk
import ./widget

type
  Entry* = ref object of Widget

  Index = string or int

proc isEntry*(w: Widget): bool = "entry" in w.pathname.split('.')[^1]

proc newEntry*(parent: Widget, text: string = "", configuration: openArray[(string, string)] = {:}): Entry =
  new result

  result.pathname = pathname(parent.pathname, genName("entry_"))
  result.tk = parent.tk

  result.tk.call("entry", result.pathname)

  result.configure({"textvariable": genName("DEFAULTVAR_string_")})

  if text.len > 0:
    result.tk.call("set", result.cget("textvariable"), tclEscape text)
  
  if configuration.len > 0:
    result.configure(configuration)

proc bbox*(e: Entry, index: Index): tuple[offsetX, offsetY, width, height: int] =
  e.tk.call($e, "bbox", index)

  if e.tk.result.len == 0:
    return
  
  let nums = e.tk.result.split()

  result.offsetX = nums[0].parseInt()
  result.offsetY = nums[1].parseInt()
  result.width = nums[2].parseInt()
  result.height = nums[3].parseInt()
proc clear*(e: Entry) = e.tk.call("set", e.cget("textvariable"), "\"\"")
proc delete*[I1, I2: Index](e: Entry, first: I1; last: I2 = "") = e.tk.call($e, "delete", first, last)
proc get*(e: Entry): string {.alias: "text".} = e.tk.call($e, "get")
proc set*(e: Entry, text: string) {.alias: "text".} = e.tk.call("set", e.cget("textvariable"), tclEscape text)
proc icursor*(e: Entry, index: Index) = e.tk.call($e, "icursor", index)
proc index*(e: Entry, index: string): int = parseInt e.tk.call($e, "index", index)
proc insert*(e: Entry, index: string, str: string) = e.tk.call($e, "insert", index, tclEscape str)
proc scanMark*(e: Entry, x: int) = e.tk.call($e, "scan mark", x)
proc scanDragTo*(e: Entry, x: int) = e.tk.call($e, "scan dragto", x)
proc selectionAdjust*(e: Entry, index: Index) = e.tk.call($e, "selection adjust", index)
proc selectionClear*(e: Entry) = e.tk.call($e, "selection clear")
proc selectionFrom*(e: Entry, index: Index) = e.tk.call($e, "selection from", index)
proc selectionPresent*(e: Entry): bool = e.tk.call($e, "selection present") == "1"
proc selectionRange*[I1, I2: Index](e: Entry, start: I1, `end`: I2) = e.tk.call($e, "selection range", start, `end`)
proc selectionTo*(e: Entry, index: Index) = e.tk.call($e, "selection to", index)
proc validate*(e: Entry): bool = e.tk.call($e, "validate") == "1"
proc xview*(e: Entry): array[2, float] =
  e.tk.call($e, "xview")

  let res = e.tk.result.split(' ')

  result[0] = parseFloat res[0]
  result[1] = parseFloat res[1]
proc xview*(e: Entry, index: Index) = e.tk.call($e, "xview", index)
proc xviewMoveto*(e: Entry, fraction: 0.0..1.0) = e.tk.call($e, "xview moveto", fraction)
proc xviewScroll*(e: Entry, number: int, what: string) = e.tk.call($e, "xview scroll", number, tclEscape what)

proc setValidateCommand*(e: Entry, command: TkEntryCommand) =
  let name = genName("entry_validate_command_")
  e.tk.registerCmd(e, name, command)
  e.configure({"validatecommand": "{$1 %d %i %P %s %S %v %V}" % name})
proc setInvalidCommand*(e: Entry, command: TkEntryCommand) =
  let name = genName("entry_invalid_command_")
  e.tk.registerCmd(e, name, command)
  e.configure({"invalidcommand": "{$1 %d %i %P %s %S %v %V}" % name})

proc `validatecommand=`*(e: Entry, command: TkEntryCommand) = e.setValidateCommand(command)
proc `invalidcommand=`*(e: Entry, command: TkEntryCommand) = e.setInvalidCommand(command)
proc `disabledbackground=`*(e: Entry, disabledbackground: Color or string) = e.configure({"disabledbackground":  tclEscape disabledbackground})
proc `disabledforeground=`*(e: Entry, disabledforeground: Color or string) = e.configure({"disabledforeground":  tclEscape disabledforeground})
proc `readonlybackground=`*(e: Entry, readonlybackground: Color or string) = e.configure({"readonlybackground":  tclEscape readonlybackground})
proc `show=`*(e: Entry, show: char) = e.configure({"show":  tclEscape show})
proc `state=`*(e: Entry, state: WidgetState) = e.configure({"state": $state})
proc `validationMode=`*(e: Entry, validationMode: ValidationMode) = e.configure({"validate": $validationMode})
proc `width=`*(e: Entry, width: int) = e.configure({"width": $width})

proc disabledbackground*(e: Entry): Color = fromTclColor e, e.cget("disabledbackground")
proc disabledforeground*(e: Entry): Color = fromTclColor e, e.cget("disabledforeground")
proc readonlybackground*(e: Entry): Color = fromTclColor e, e.cget("readonlybackground")
proc show*(e: Entry): char = e.cget("show")[0]
proc state*(e: Entry): WidgetState = parseEnum[WidgetState] e.cget("state")
proc validationMode*(e: Entry): ValidationMode = parseEnum[ValidationMode] e.cget("validate")
proc width*(e: Entry): int = parseInt e.cget("width")
