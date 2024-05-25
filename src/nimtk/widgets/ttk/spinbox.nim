import std/sequtils
import std/strutils

import ../../utils/escaping
import ../../utils/genname
import ../../utils/tcllist
import ../../../nimtk
import ../widget
import ./widget

type
  TtkSpinbox* = ref object of TtkWidget

proc isTtkSpinbox*(w: Widget): bool = "ttkspinbox" in w.pathname.split('.')[^1]

proc newTtkSpinbox*(parent: Widget, values: openArray[string] = [], configuration: openArray[(string, string)] = {:}): TtkSpinbox =
  new result

  result.pathname = pathname(parent.pathname, genName("ttkspinbox_"))
  result.tk = parent.tk

  result.tk.call("ttk::spinbox", result.pathname)

  if values.len > 0:
    result.configure({"values": values.map(tclEscape).toTclList()})
  
  if configuration.len > 0:
    result.configure(configuration)

proc get*(s: TtkSpinbox): string = s.tk.call($s, "get")
proc set*(s: TtkSpinbox, text: string) = s.tk.call($s, "set", tclEscape text)

proc setValidateCommand*(s: TtkSpinbox, command: TkEntryCommand) =
  let name = genName("ttkspinbox_validate_command_")
  s.tk.registerCmd(s, name, command)
  s.configure({"validatecommand": "{$1 %d %i %P %s %S %v %V}" % name})
proc setCommand*(s: TtkSpinbox, command: TkSpinboxCommand) =
  let name = genName("ttkspinbox_command_")
  s.tk.registerCmd(s, name, command)
  s.configure({"command": "{$1 %d}" % name})

proc `validatecommand=`*(s: TtkSpinbox, command: TkEntryCommand) = s.setValidateCommand(command)
proc `command=`*(s: TtkSpinbox, command: TkSpinboxCommand) = s.setCommand(command)
proc `format=`*(s: TtkSpinbox, format: string) = s.configure({"format":  tclEscape format})
proc `from=`*(s: TtkSpinbox, num: float) = s.configure({"from": $num})
proc `increment=`*(s: TtkSpinbox, increment: float) = s.configure({"increment": $increment})
proc `to=`*(s: TtkSpinbox, to: float) = s.configure({"to": $to})
proc `values=`*(s: TtkSpinbox, values: openArray[string]) = s.configure({"values": values.map(tclEscape).toTclList()})
proc `wrap=`*(s: TtkSpinbox, wrap: bool) = s.configure({"wrap": $wrap})

proc format*(s: TtkSpinbox): string = s.cget("format")
proc `from`*(s: TtkSpinbox): float = parseFloat s.cget("from")
proc increment*(s: TtkSpinbox): float = parseFloat s.cget("increment")
proc to*(s: TtkSpinbox): float = parseFloat s.cget("to")
proc values*(s: TtkSpinbox): seq[string] = s.cget("values").split(' ')
proc wrap*(s: TtkSpinbox): bool = s.cget("wrap") == "1"
