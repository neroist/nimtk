import std/strutils
import std/colors

import ../../utils/escaping
import ../../utils/tclcolor
import ../../utils/genname
import ../../utils/alias
import ../../variables
import ../../../nimtk
import ../widget

type
  TtkEntry* = ref object of TtkWidget

  Index = string or int

proc isTtkEntry*(w: Widget): bool = "ttkentry" in w.pathname.split('.')[^1]

proc newTtkEntry*(parent: Widget, text: string = "", configuration: openArray[(string, string)] = {:}): TtkEntry =
  new result

  result.pathname = pathname(parent.pathname, genName("ttkentry_"))
  result.tk = parent.tk

  result.tk.call("ttk::entry", result.pathname)

  result.configure({"textvariable": genName("DEFAULTVAR_string_")})

  if text.len > 0:
    result.tk.call("set", result.cget("textvariable"), tclEscape text)
  
  if configuration.len > 0:
    result.configure(configuration)

proc bbox*(e: TtkEntry, index: Index): tuple[offsetX, offsetY, width, height: int] =
  e.call("bbox", index)

  if e.tk.result.len == 0:
    return
  
  let nums = e.tk.result.split()

  result.offsetX = nums[0].parseInt()
  result.offsetY = nums[1].parseInt()
  result.width = nums[2].parseInt()
  result.height = nums[3].parseInt()
proc clear*(e: TtkEntry) = e.tk.call("set", e.cget("textvariable"), "\"\"")
proc delete*[I1, I2: Index](e: TtkEntry, first: I1; last: I2 = "") = e.call("delete", first, last)
proc get*(e: TtkEntry): string {.alias: "text".} = e.call("get")
proc set*(e: TtkEntry, text: string) {.alias: "text".} = e.tk.call("set", e.cget("textvariable"), tclEscape text)
proc icursor*(e: TtkEntry, index: Index) = e.call("icursor", index)
proc index*(e: TtkEntry, index: string): int = parseInt e.call("index", index)
proc insert*(e: TtkEntry, index: string, str: string) = e.call("insert", index, tclEscape str)
proc scanMark*(e: TtkEntry, x: int) = e.call("scan mark", x)
proc scanDragTo*(e: TtkEntry, x: int) = e.call("scan dragto", x)
proc selectionAdjust*(e: TtkEntry, index: Index) = e.call("selection adjust", index)
proc selectionClear*(e: TtkEntry) = e.call("selection clear")
proc selectionFrom*(e: TtkEntry, index: Index) = e.call("selection from", index)
proc selectionPresent*(e: TtkEntry): bool = e.call("selection present") == "1"
proc selectionRange*[I1, I2: Index](e: TtkEntry, start: I1, `end`: I2) = e.call("selection range", start, `end`)
proc selectionTo*(e: TtkEntry, index: Index) = e.call("selection to", index)
proc validate*(e: TtkEntry): bool = e.call("validate") == "1"
proc xview*(e: TtkEntry): array[2, float] =
  e.call("xview")

  let res = e.tk.result.split(' ')

  result[0] = parseFloat res[0]
  result[1] = parseFloat res[1]
proc xview*(e: TtkEntry, index: Index) = e.call("xview", index)
proc xviewMoveto*(e: TtkEntry, fraction: 0.0..1.0) = e.call("xview moveto", fraction)
proc xviewScroll*(e: TtkEntry, number: int, what: string) = e.call("xview scroll", number, tclEscape what)

proc setValidateCommand*(e: TtkEntry, command: TkEntryCommand) =
  let name = genName("ttkentry_validate_command_")
  e.tk.registerCmd(e, name, command)
  e.configure({"validatecommand": "{$1 %d %i %P %s %S %v %V}" % name})
proc setInvalidCommand*(e: TtkEntry, command: TkEntryCommand) =
  let name = genName("ttkentry_invalid_command_")
  e.tk.registerCmd(e, name, command)
  e.configure({"invalidcommand": "{$1 %d %i %P %s %S %v %V}" % name})

proc `exportselection=`*(e: TtkEntry, exportselection: bool) = e.configure({"exportselection": $exportselection})
proc `validatecommand=`*(e: TtkEntry, command: TkEntryCommand) = e.setValidateCommand(command)
proc `invalidcommand=`*(e: TtkEntry, command: TkEntryCommand) = e.setInvalidCommand(command)
proc `disabledbackground=`*(e: TtkEntry, disabledbackground: Color or string) = e.configure({"disabledbackground":  tclEscape disabledbackground})
proc `disabledforeground=`*(e: TtkEntry, disabledforeground: Color or string) = e.configure({"disabledforeground":  tclEscape disabledforeground})
proc `readonlybackground=`*(e: TtkEntry, readonlybackground: Color or string) = e.configure({"readonlybackground":  tclEscape readonlybackground})
proc `show=`*(e: TtkEntry, show: char) = e.configure({"show":  tclEscape show})
proc `state=`*(e: TtkEntry, state: WidgetState) = e.configure({"state": $state})
proc `validationMode=`*(e: TtkEntry, validationMode: ValidationMode) = e.configure({"validate": $validationMode})
proc `width=`*(e: TtkEntry, width: int) = e.configure({"width": $width})

proc exportselection*(e: TtkEntry): bool = parseBool e.cget("exportselection")
proc disabledbackground*(e: TtkEntry): Color = fromTclColor e, e.cget("disabledbackground")
proc disabledforeground*(e: TtkEntry): Color = fromTclColor e, e.cget("disabledforeground")
proc readonlybackground*(e: TtkEntry): Color = fromTclColor e, e.cget("readonlybackground")
proc show*(e: TtkEntry): char = e.cget("show")[0]
proc state*(e: TtkEntry): WidgetState = parseEnum[WidgetState] e.cget("state")
proc validationMode*(e: TtkEntry): ValidationMode = parseEnum[ValidationMode] e.cget("validate")
proc width*(e: TtkEntry): int = parseInt e.cget("width")
