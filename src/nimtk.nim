import std/strutils

import nimtcl/tk as _ # avoid name conflicts
import nimtcl

import nimtk/exceptions

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

  Cursor* {.pure.} = enum
    XCursor = "X_cursor"
    Arrow = "arrow"
    BasedArrowDown = "based_arrow_down"
    BasedArrowUp = "based_arrow_up"
    Boat = "boat"
    Bogosity = "bogosity"
    BottomLeftCorner = "bottom_left_corner"
    BottomRightCorner = "bottom_right_corner"
    BottomSide = "bottom_side"
    BottomTee = "bottom_tee"
    BoxSpiral = "box_spiral"
    CenterPtr = "center_ptr"
    Circle = "circle"
    Clock = "clock"
    CoffeeMug = "coffee_mug"
    Cross = "cross"
    CrossReverse = "cross_reverse"
    Crosshair = "crosshair"
    DiamondCross = "diamond_cross"
    Dot = "dot"
    Dotbox = "dotbox"
    DoubleArrow = "double_arrow"
    DraftLarge = "draft_large"
    DraftSmall = "draft_small"
    DrapedBox = "draped_box"
    Exchange = "exchange"
    Fleur = "fleur"
    Gobbler = "gobbler"
    Gumby = "gumby"
    Hand1 = "hand1"
    Hand2 = "hand2"
    Heart = "heart"
    Icon = "icon"
    IronCross = "iron_cross"
    LeftPtr = "left_ptr"
    LeftSide = "left_side"
    LeftTee = "left_tee"
    Leftbutton = "leftbutton"
    LlAngle = "ll_angle"
    LrAngle = "lr_angle"
    Man = "man"
    Middlebutton = "middlebutton"
    Mouse = "mouse"
    None = "none"
    Pencil = "pencil"
    Pirate = "pirate"
    Plus = "plus"
    QuestionArrow = "question_arrow"
    RightPtr = "right_ptr"
    RightSide = "right_side"
    RightTee = "right_tee"
    Rightbutton = "rightbutton"
    RtlLogo = "rtl_logo"
    Sailboat = "sailboat"
    SbDownArrow = "sb_down_arrow"
    SbHDoubleArrow = "sb_h_double_arrow"
    SbLeftArrow = "sb_left_arrow"
    SbRightArrow = "sb_right_arrow"
    SbUpArrow = "sb_up_arrow"
    SbVDoubleArrow = "sb_v_double_arrow"
    Shuttle = "shuttle"
    Sizing = "sizing"
    Spider = "spider"
    Spraycan = "spraycan"
    Star = "star"
    Target = "target"
    Tcross = "tcross"
    TopLeftArrow = "top_left_arrow"
    TopLeftCorner = "top_left_corner"
    TopRightCorner = "top_right_corner"
    TopSide = "top_side"
    TopTee = "top_tee"
    Trek = "trek"
    UlAngle = "ul_angle"
    Umbrella = "umbrella"
    UrAngle = "ur_angle"
    Watch = "watch"
    Xterm = "xterm"

    # Windows-specific
    winNo = "no"
    winStarting = "starting"
    winSize = "size"
    winSizeNeSw = "size_ne_sw"
    winSizeNs = "size_ns"
    winSizeNwSe = "size_nw_se"
    winSizeWe = "size_we"
    winUparrow = "uparrow"
    winWait = "wait"

    # MacOSX-specific
    macCopyarrow = "copyarrow"
    macAliasarrow = "aliasarrow"
    macContextualmenuarrow = "contextualmenuarrow"
    macMovearrow = "movearrow"
    macText = "text"
    macCrossHair = "cross-hair"
    macHand = "hand"
    macOpenhand = "openhand"
    macClosedhand = "closedhand"
    macFist = "fist"
    macPointinghand = "pointinghand"
    macResize = "resize"
    macResizeleft = "resizeleft"
    macResizeright = "resizeright"
    macResizeleftright = "resizeleftright"
    macResizeup = "resizeup"
    macResizedown = "resizedown"
    macResizeupdown = "resizeupdown"
    macResizebottomleft = "resizebottomleft"
    macResizetopleft = "resizetopleft"
    macResizebottomright = "resizebottomright"
    macResizetopright = "resizetopright"
    macNotallowed = "notallowed"
    macPoof = "poof"
    # macWait = "wait"
    macCountinguphand = "countinguphand"
    macCountingdownhand = "countingdownhand"
    macCountingupanddownhand = "countingupanddownhand"
    macSpinning = "spinning"
    macHelp = "help"
    macBucket = "bucket"
    macCancel = "cancel"
    macEyedrop = "eyedrop"
    macEyedropFull = "eyedrop-full"
    macZoomIn = "zoom-in"
    macZoomOut = "zoom-out"

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

  PositionFrom* {.pure.} = enum # TODO change name
    User = "user"
    Program = "program"

  WindowState* {.pure.} = enum
    Normal = "normal"
    Iconic = "iconic"
    Withdrawn = "withdrawn"
    Icon = "icon"
    Zoomed = "zoomed"

  Tk* = ref object
    interp*: ptr Interp

const nimTkDebug* {.booldefine.} = false

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

  if result != TCL_OK:
    raise newException(
      TkError,
      "Error when evaluating Tcl!\n" &
      "Command: " & cmd & "\n" &
      "Result: " & $tk.interp.getStringResult()
    )

proc call*(tk: Tk, cmd: string, args: varargs[string, `$`]): int {.discardable.} =
  tk.eval(cmd & " " & args.join(" ").strip())

proc result*(tk: Tk): string =
  $tk.interp.getStringResult()

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
