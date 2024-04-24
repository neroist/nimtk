import std/strutils
import std/macros
import std/with

import nimtk/exceptions
import nimtcl/tk
import nimtcl

include nimtk/cursors

type
  AnchorPosition* {.pure.} = enum
    Center = "center"
    North = "n"
    Northeast = "ne"
    East = "e"
    Southeast = "se"
    South = "s"
    Southwest = "sw"
    West = "w"
    Northwest = "nw"

  FillStyle* {.pure.} = enum
    None = "none"
    X = "x"
    Y = "y"
    Both = "both"

  Side* {.pure.} = enum
    Top = "top"
    Left = "left"
    Right = "right"
    Bottom = "bottom"

  BorderMode* {.pure.} = enum
    Inside = "inside"
    Outside = "outside"
    Ignore = "ignore"

  MessageBoxType* {.pure.} = enum
    AbortRetryIgnore = "abortretryignore"
    Ok = "ok"
    OkCancel = "okcancel"
    RetryCancel = "retrycancel"
    YesNo = "yesno"
    YesNoCancel = "yesnocancel"

  IconImage* {.pure.} = enum
    Error = "error"
    Info = "info"
    Question = "question"
    Warning = "warning"

  ButtonName* {.pure.} = enum
    Default = ""
    Abort = "abort"
    Retry = "retry"
    Ignore = "ignore"
    Ok = "ok"
    Canvel = "canvel"
    Yes = "yes"
    No = "no"

  WidgetCompound* {.pure.} = enum
    None = "none"
    Bottom = "bottom"
    Top = "top"
    Left = "left"
    Right = "right"
    Center = "center"

  TextJustify* {.pure.} = enum
    Left = "left"
    Right = "right"
    Center = "center"

  WidgetOrientation* {.pure.} = enum
    Horizontal = "horizontal"
    Vertical = "vertical"

  WidgetRelief* {.pure.} = enum
    Raised = "raised"
    Sunken = "sunken"
    Flat = "flat"
    Ridge = "ridge"
    Solid = "solid"
    Groove = "groove"

  WindowType* {.pure.} = enum
    Desktop = "desktop"
    Dock = "dock"
    Toolbar = "toolbar"
    Menu = "menu"
    Utility = "utility"
    Splash = "splash"
    Dialog = "dialog"
    DropdownMenu = "dropdown_menu"
    PopupMenu = "popup_menu"
    Tooltip = "tooltip"
    Notification = "notification"
    Combo = "combo"
    Dnd = "dnd"
    Normal = "normal"

  FocusModel* {.pure.} = enum
    Active = "active"
    Passive = "passive"

  GeometryFrom* {.pure.} = enum # TODO change name
    User = "user"
    Program = "program"

  WindowState* {.pure.} = enum
    Normal = "normal"
    Iconic = "iconic"
    Withdrawn = "withdrawn"
    Icon = "icon"
    Zoomed = "zoomed"

  WidgetState* {.pure.} = enum
    Normal = "normal"
    Active = "active"
    Disabled = "disabled"
    ReadOnly = "readonly"

  AfterEventHandler* {.pure.} = enum
    Idle
    Timer

  VisualClass* {.pure.} = enum
    Directcolor
    Grayscale
    Pseudocolor
    Staticcolor
    Staticgray
    Truecolor

  ValidationMode* {.pure.} = enum 
    None = "none"
    Focus = "focus"
    Focusin = "focusin"
    Focusout = "focusout"
    Key = "key"
    All = "all"

  ActiveStyle* {.pure.} = enum
    Dotbox = "dotbox"
    None = "none"
    Underline = "underline"

  SelectMode* {.pure.} = enum
    Single = "single"
    Browse = "browse"
    Multiple = "multiple"
    Extended = "extended"

  ScrollbarElement* {.pure.} = enum
    Arrow1 = "arrow1"
    Trough1 = "trough1"
    Slider = "slider"
    Trough2 = "trough2"
    Arrow2 = "arrow2"
  
  # ValidationTrigger* {.pure.} = enum 
  #   Focusin = "focusin"
  #   Focusout = "focusout"
  #   Key = "key"
  #   Forced = "forced"

  Tk* = ref object
    interp*: ptr Interp

const
  nimtkDebug* {.booldefine: "nimtk.debug".} = false
  nimtkIgnoreTclErrors* {.booldefine: "nimtk.ignoreTclErrors".} = false

proc toArgs*(map: openArray[tuple[name, val: string]]): string =
  for tup in map:
    if tup.val.len == 0: continue

    result.add "-" & tup.name & " " & tup.val.strip() & " "

proc eval*(tk: Tk, cmd: string): int {.discardable.} =
  result = tk.interp.eval(cstring cmd)

  when nimTkDebug:
    echo "[TK EVAL]   ", cmd
    echo "[TK RETURN] ", result
    echo "[TK RESULT] ", tk.interp.getStringResult(), "\n"

  if result != TCL_OK and not nimtkIgnoreTclErrors:
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

proc createCommand*(tk: Tk, name: string, clientdata: pointer, fun: CmdProc) =
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
  