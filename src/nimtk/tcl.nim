import std/strutils

import ./private/tcllist
import ./private/escaping
import ./widgets/widget
import ./private/alias
import ../nimtk

type
  TraceOps* = enum
    # toRename = "rename"
    # toDelete = "delete"
    # toEnterstep = "enterstep"
    # toLeavestep = "leavestep"
    
    # toArray = "array"
    toRead = "read"
    toWrite = "write"
    toUnset = "unset"

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

# --- trace

proc traceAdd*(v: TkVar, ops: openArray[TraceOps], clientdata: pointer, command: TkGenericCommand): string {.discardable, alias: "trace".} =
  let cmdname = genName("trace_command_" & ops.join("_").replace("to", "") & "_")
  
  v.tk.registerCmd(clientdata, cmdname, command)

  v.tk.call("trace add variable", v.varname, ops.toTclList(), cmdname)

  return cmdname

proc traceRemove*(v: TkVar, ops: openArray[TraceOps], command: string) =
  v.tk.call("trace remove variable", v.varname, ops.toTclList(), command)

# proc traceInfo*(v: TkVar): seq[tuple[opList: seq[TraceOps], command: string]] =

