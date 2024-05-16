import std/sequtils
import std/strutils

import ./utils/genname
import ./utils/tcllist
import ./widgets/widget
import ./utils/alias
import ./variables
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

proc after*(tk: Tk, ms: int, fn: TkGenericCommand): int {.discardable.} =
  let name = genName("after_command_")
  
  tk.registerCmd(name, fn)

  parseInt tk.call("after", ms, name)

proc afterIdle*(tk: Tk, fn: TkGenericCommand): int {.discardable.} =
  let name = genName("after_command_")
  
  tk.registerCmd(name, fn)

  parseInt tk.call("after idle", name)

proc afterCancel*(tk: Tk, id: int) =
  tk.call("after cancel", id)

proc afterInfo*(tk: Tk): seq[int] =
  # returns a list of numerical ids
  # i see no reason why this may fail with `split`
  tk.call("after info").split(' ').map(parseInt)

proc afterInfo*(tk: Tk, id: int): AfterEventHandler =
  tk.call("after info", id)

  AfterEventHandler tk.result.split(' ')[1] == "timer"

# --- update

proc update*(tk: Tk, idletasks: bool = false) =
  if idletasks:
    tk.call("update idletasks")
  else:
    tk.call("update")

# --- trace

proc traceAdd*(v: TkVar, ops: openArray[TraceOps], command: TkGenericCommand): string {.discardable, alias: "trace".} =
  let cmdname = genName("trace_command_" & ops.join("_").replace("to", "") & "_")
  
  v.tk.registerCmd(cmdname, command)

  v.tk.call("trace add variable", v.varname, ops.toTclList(), cmdname)

  return cmdname

proc traceRemove*(v: TkVar, ops: openArray[TraceOps], command: string) =
  v.tk.call("trace remove variable", v.varname, ops.toTclList(), command)

# proc traceInfo*(v: TkVar): seq[tuple[opList: seq[TraceOps], command: string]] =

