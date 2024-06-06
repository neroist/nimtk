from std/with import nil

import std/strutils
import std/macros

import nimtk/exceptions
import nimtcl/tk/img
import nimtk/enums
import nimtcl/tk
import nimtcl


type
  Tk* = ref object
    interp*: ptr Interp

const
  nimtkDebug* {.booldefine: "nimtk.debug".} = false
  nimtkIgnoreTclErrors* {.booldefine: "nimtk.ignoreTclErrors".} = false
  nimtkExitOnError* {.booldefine: "nimtk.exitOnError".} = true

proc eval*(tk: Tk, cmd: string): int {.discardable.} =
  ## Evaluate Tcl command `cmd`.
  ##
  ## When `nimtk.debug` is defined, this routine will print out
  ##   - the command being evaluated
  ##   - the value returned by `tk.interp.eval` (usually either `0` (`TCL_OK`) or `1` (`TCL_ERROR`))
  ##   - the result of the command
  ## In that order.
  ##
  ## Example of such:
  ##
  ## ```
  ## [TK EVAL]   wm geometry .
  ## [TK RETURN] 0
  ## [TK RESULT] 800x600+560+225
  ## ```
  ##
  ## When `1` (`TCL_ERROR`) is retured by the Tcl interpreter, a `TkError` is raised,
  ## containing the the command and the result.
  ##
  ## If `nimtk.exitOnError` is defined, then the program is terminated upon any
  ## error raised by the interpreter. This flag is to avoid application freezing
  ## upon errors.
  ##
  ## `nimtk.ignoreTclErrors` holds higher presedence than the aforementioned flag,
  ## and will result in all Tcl errors being ignored. No exceptions will be raised.
  ##
  ## :tk: The Tk instance to use to evaluate the command
  ## :cmd: Command to be evaluated

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
  ## Returns the current result of the Tcl interpreter in `tk`

  $tk.interp.getStringResult()

proc call*(tk: Tk, cmd: string, args: varargs[string, `$`]): string {.discardable.} =
  ## Evalutate `cmd` with arguments `args`, and return the result. This uses `eval`_.
  ##
  ## :tk: The Tk instance to evaluate the command with
  ## :cmd: The base command to evaluate
  ## :args: List of arguments to provide to `cmd`
  
  tk.eval(cmd & " " & args.join(" ").strip())
  tk.result

proc mainloop*(tk: Tk) =
  ## Calls Tk mainloop

  tkMainloop()

proc createCommand*(tk: Tk, name: string, clientData: pointer, fun: CmdProc) =
  ## Creates a command in the Tcl interpreter
  ##
  ## Shortcut for `discard tk.interp.createCommand(...)`
  
  discard tk.interp.createCommand(
    name,
    fun,
    clientdata
  )

proc init*(tk: Tk) =
  ## Initialise Tcl interpreter & Tk

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

proc imgInit*(tk: Tk) =
  ## Initialise Img library (allows for more image formats to be used with Tk)

  let init = tk.interp.imgInit()

  if init != TCL_OK:
    const errmsg = "Could not initialize Img"

    raise newException(
      TkError,
      errmsg & " -- " & repr $tk.interp.getStringResult()
    )

proc newTk*(): Tk =
  ## Creates new `Tk` instance with a Tcl interpeter. Calls `init`_ for you.

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
  enums

macro config*(arg: typed; calls: varargs[untyped]) =
  ## Config macro which allows you to configure widgets with a single function call
  ##
  ## Same as the `with` macro from `std/with` but with no re-evaluation.

  result = newStmtList()

  result.add:
    if arg.kind != nnkIdent:
      quote do:
        # let argvar = `arg`
        with.with(`arg`, `calls`)
    else:
      quote do:
        let argvar = `arg`
        with.with(argvar, `calls`)

        # needed to avoid segmentation faults on *arc and orc, see #3
        discard argvar
