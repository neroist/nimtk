import std/strutils
import std/macros
import std/with

import nimtk/exceptions
import nimtcl/tk
import nimtcl

include nimtk/enums

type
  Tk* = ref object
    interp*: ptr Interp

const
  nimtkDebug* {.booldefine: "nimtk.debug".} = false
  nimtkIgnoreTclErrors* {.booldefine: "nimtk.ignoreTclErrors".} = false
  nimtkExitOnError* {.booldefine: "nimtk.ExitOnError".} = true

proc eval*(tk: Tk, cmd: string): int {.discardable.} =
  result = tk.interp.eval(cstring cmd)

  when nimTkDebug:
    echo "[TK EVAL]   ", cmd
    echo "[TK RETURN] ", result
    echo "[TK RESULT] ", tk.interp.getStringResult(), "\n"

  if result == TCL_ERROR and not nimtkIgnoreTclErrors:
    when nimtkExitOnError:
      tk.interp.eval("exit 1")
    
    raise newException(
      TkError,
      "Error when evaluating Tcl!\n\n" &
      "Command: $1\n" % cmd & 
      "Result: $1" % $tk.interp.getStringResult()
    )

proc result*(tk: Tk): string =
  $tk.interp.getStringResult()

proc call*(tk: Tk, cmd: string, args: varargs[string, `$`]): string {.discardable.} =
  tk.eval(cmd & " " & args.join(" ").strip())
  tk.result

proc mainloop*(tk: Tk) =
  tkMainloop()

proc createCommand*(tk: Tk, name: string, clientData: pointer, fun: CmdProc) =
  discard tk.interp.createCommand(
    name,
    fun,
    clientdata
  )

proc init*(tk: Tk) =
  let tclInit = tk.interp.init()
  let tkInit = tk.interp.tkInit()

  if tclInit != TCL_OK:
    const errmsg = "Could not initialize Tcl"

    raise newException(
      TkError,
      errmsg
    )

  if tkInit != TCL_OK:
    const errmsg = "Could not initialize Tk"
    
    raise newException(
      TkError,
      errmsg & " -- " & repr $tk.interp.getStringResult()
    )

proc newTk*(): Tk =
  new result

  result.interp = createInterp()

  if result.interp == nil:
    raise newException(
      TkError,
      "Could not create Tcl interpreter!"
    )

  result.init()

export
  exceptions,
  with

macro config*(arg: typed; calls: varargs[untyped]) = quote do: with(`arg`, `calls`)
  