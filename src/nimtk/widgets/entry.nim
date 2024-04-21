import std/strutils

import ../../nimtk
import ./widget

type
  Entry* = ref object of Widget
  Index = string or int

proc newEntry*(parent: Widget, text: string = "", configuration: openArray[(string, string)] = {:}): Entry =
  new result

  result.pathname = pathname(parent.pathname, genName("entry_"))
  result.tk = parent.tk

  result.tk.call("entry", result.pathname)

  if text.len > 0:
    result.configure({"text": repr text})
  
  if configuration.len > 0:
    result.configure(configuration)

#! bbox

proc delete*(e: Entry, first: Index; last: Index = "") = e.tk.call($e, "delete", first, last)
proc get*(e: Entry): string = e.tk.call($e, "get")
proc icursor*(e: Entry, index: Index) = e.tk.call($e, "icursor", index)
proc index*(e: Entry, index: string): int = parseInt e.tk.call($e, "index", index)
proc scanMark*(e: Entry, x: int) = e.tk.call($e, "scan mark", x)
proc scanDragTo*(e: Entry, x: int) = e.tk.call($e, "scan dragto", x)
proc selectionAdjust*(e: Entry, index: Index) = e.tk.call($e, "selection adjust", index)
proc selectionClear*(e: Entry) = e.tk.call($e, "selection clear")
proc selectionFrom*(e: Entry, index: Index) = e.tk.call($e, "selection from", index)
proc selectionPresent*(e: Entry): bool = e.tk.call($e, "selection present") == "1"
proc selectionRange*(e: Entry, start, `end`: Index) = e.tk.call($e, "selection range", start, `end`)
proc selectionTo*(e: Entry, index: Index) = e.tk.call($e, "selection to", index)
proc validate*(e: Entry) = e.tk.call($e, "validate")

proc setCommand*(e: Entry, clientData: pointer, command: TkWidgetCommand) =
  let name = genName("button_command_")
  
  e.tk.registerCmd(e, clientdata, name, command)

  e.configure({"command": name})
proc `command=`*(e: Entry, command: TkWidgetCommand) = e.setCommand(nil, command)
proc `default=`*(e: Entry, default: WidgetState) = e.configure({"default": $default})
proc `height=`*(e: Entry, height: string or float or int) = e.configure({"height": $height})
proc `overrelief=`*(e: Entry, overrelief: WidgetRelief) = e.configure({"overrelief": $overrelief})
proc `state=`*(e: Entry, state: WidgetState) = e.configure({"state": $state})
proc `width=`*(e: Entry, width: string or float or int) = e.configure({"width": $width})

proc default*(e: Entry): WidgetState = parseEnum[WidgetState] e.cget("default")
proc height*(e: Entry): string = e.cget("height")
proc overrelief*(e: Entry): WidgetRelief = parseEnum[WidgetRelief] e.cget("overrelief")
proc state*(e: Entry): WidgetState = parseEnum[WidgetState] e.cget("state")
proc width*(e: Entry): string = e.cget("width")
