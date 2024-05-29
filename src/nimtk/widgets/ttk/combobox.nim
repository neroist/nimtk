import std/sequtils
import std/strutils

import ../../utils/escaping
import ../../utils/genname
import ../../utils/tcllist
import ../../../nimtk
import ../widget
import ./widget

type
  Combobox* = ref object of TtkWidget

  Index = int or string

proc isCombobox*(w: Widget): bool = "combobox" in w.pathname.split('.')[^1]

proc newCombobox*(parent: Widget, values: openArray[string] = [], configuration: openArray[(string, string)] = {:}): Combobox =
  new result

  result.pathname = pathname(parent.pathname, genName("combobox_"))
  result.tk = parent.tk

  result.tk.call("ttk::combobox", result.pathname)

  if values.len > 0:
    result.configure({"values": values.map(tclEscape).toTclList()})
  
  if configuration.len > 0:
    result.configure(configuration)

proc current*(c: Combobox, newIndex: Index) = c.call("current", tclEscape newIndex)
proc current*(c: Combobox): int = parseInt c.call("current")
proc get*(c: Combobox): string = c.call("get")
proc set*(c: Combobox, value: string) = c.call("set", value)

# entry subcommands
proc bbox*(c: Combobox, index: Index): tuple[offsetX, offsetY, width, height: int] =
  c.call("bbox", index)

  if c.tk.result.len == 0:
    return
  
  let nums = c.tk.result.split()

  result.offsetX = nums[0].parseInt()
  result.offsetY = nums[1].parseInt()
  result.width = nums[2].parseInt()
  result.height = nums[3].parseInt()
proc clear*(c: Combobox) = c.tk.call("set", c.cget("textvariable"), "\"\"")
proc delete*[I1, I2: Index](c: Combobox, first: I1; last: I2 = "") = c.call("delete", first, last)
proc icursor*(c: Combobox, index: Index) = c.call("icursor", index)
proc index*(c: Combobox, index: string): int = parseInt c.call("index", index)
proc insert*(c: Combobox, index: string, str: string) = c.call("insert", index, tclEscape str)
proc selectionAdjust*(c: Combobox, index: Index) = c.call("selection adjust", index)
proc selectionClear*(c: Combobox) = c.call("selection clear")
proc selectionFrom*(c: Combobox, index: Index) = c.call("selection from", index)
proc selectionPresent*(c: Combobox): bool = c.call("selection present") == "1"
proc selectionRange*[I1, I2: Index](c: Combobox, start: I1, `end`: I2) = c.call("selection range", start, `end`)
proc selectionTo*(c: Combobox, index: Index) = c.call("selection to", index)
proc xview*(c: Combobox): array[2, float] =
  c.call("xview")

  let res = c.tk.result.split(' ')

  result[0] = parseFloat res[0]
  result[1] = parseFloat res[1]
proc xview*(c: Combobox, index: Index) = c.call("xview", index)
proc xviewMoveto*(c: Combobox, fraction: 0.0..1.0) = c.call("xview moveto", fraction)
proc xviewScroll*(c: Combobox, number: int, what: string) = c.call("xview scroll", number, tclEscape what)

proc `exportSelection=`*(c: Combobox, exportSelection: bool) = c.configure({"exportselection": $exportSelection})
proc `height=`*(c: Combobox, height: int) = c.configure({"height": $height})
proc setPostCommand*(c: Combobox, command: TkGenericCommand) =
  let name = genName("combobox_command_")
  c.tk.registerCmd(c, name, command)
  c.configure({"command": "{$1 %d}" % name})
proc `postcommand=`*(c: Combobox, command: TkGenericCommand) = c.setPostCommand(command)
proc `state=`*(c: Combobox, state: WidgetState) = c.configure({"state": $state})
proc `values=`*(c: Combobox, values: openArray[string]) = c.configure({"values": values.toTclList()})
proc `width=`*(c: Combobox, width: int) = c.configure({"width": $width})

proc exportSelection*(c: Combobox): bool = c.cget("exportselection") == "1"
proc height*(c: Combobox): int = parseInt c.cget("height")
proc state*(c: Combobox): WidgetState = parseEnum[WidgetState] c.cget("state")
proc values*(c: Combobox): seq[string] = fromTclList c.tk, c.cget("values")
proc width*(c: Combobox): int = parseInt c.cget("width")
