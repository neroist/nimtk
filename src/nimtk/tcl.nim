import std/strutils

import ./private/escaping
import ./widgets/widget
import ./private/alias
import ../nimtk

# --- after

# procs will return an int

proc after*(tk: Tk, ms: int) {.alias: "sleep".} =
  tk.call("after", ms)

proc after*(tk: Tk, ms: int, clientdata: pointer, fn: TkGenericCommand): int =
  let name = genName("after_generic_command_")
  
  tk.registerCmd(clientdata, name, fn)

  tk.call("after", ms, name)
  tk.result.parseInt()

proc afterIdle*(tk: Tk, clientdata: pointer, fn: TkGenericCommand): int =
  let name = genName("after_generic_command_")
  
  tk.registerCmd(clientdata, name, fn)

  tk.call("after idle", name)
  tk.result.parseInt()

proc afterCancel*(tk: Tk, id: int) =
  tk.call("after cancel", id)

proc afterInfo*(tk: Tk): seq[int] =
  tk.call("after info")

  for id in tk.result.split(" "):
    result.add id.parseInt()

proc afterInfo*(tk: Tk, id: int): AfterEventHandler =
  tk.call("after info", id)

  AfterEventHandler tk.result.split(" ")[1] == "timer"

# --- update

proc update*(tk: Tk, idletasks: bool = false) =
  if idletasks:
    tk.call("update idletasks")
  else:
    tk.call("update")
