import std/strutils
import std/tables
import std/colors
import std/times

import nimtcl except Time

import ../private/escaping
import ../private/alias
import ../variables
import ../../nimtk
import ../keysyms

export variables

type
  Widget* = ref object of RootObj
    pathname*: string
    tk*: Tk
  
  TkWidgetCommand* = proc (widget: Widget, clientdata: pointer)
  TkSelectionHandleCommand* = proc (offset, maxChars: int, clientdata: pointer): string
  TkGenericCommand* = proc (clientdata: pointer)
  TkEventCommand* = proc (event: Event, clientdata: pointer)
  TkScaleCommand* = proc (widget: Widget, newvalue: float, clientdata: pointer)
  TkEntryCommand* = proc (widget: Widget, event: EntryEvent, clientdata: pointer): bool
  
  TkCmdData[CMD] = ref object of RootObj
    clientdata*: pointer
    fun*: CMD

  TkWidgetCmdData*[CMD] = ref object of TkCmdData[CMD]
    widget*: Widget

  Padding* = (SomeNumber, SomeNumber) or # these two have to be the same type
             (string, string)         or
             (string, SomeNumber)     or
             (SomeNumber, string)     or
             SomeNumber               or
             string
  
  EntryEvent* = object
    actionType: int
    charIndex*: int
    editedValue*: string
    currentValue*: string
    edit*: string
    validationMode*: ValidationMode
    validationTrigger*: string # opt

  EventType* = enum
    Activate
    Destroy
    Map
    ButtonPress
    Enter
    MapRequest
    ButtonRelease
    Expose
    Motion
    Circulate
    FocusIn
    MouseWheel
    CirculateRequest
    FocusOut
    Property
    Colormap
    Gravity
    Reparent
    Configure
    KeyPress
    ResizeRequest
    ConfigureRequest
    KeyRelease
    Unmap
    Create
    Leave
    Visibility
    Deactivate

  Event* = object
    # event data
    serial*: int
    above*: Widget
    button*: int
    count*: int
    userData*: string # opt
    focus*: bool
    height*: int
    window*: Widget
    keycode*: int
    mode*: string # opt
    override*: bool
    place*: string # opt
    state*: string 
    time*: int # times.Time?
    width*: int
    x*, y*: int
    #? unicodeChar*: Utf16Char # unicode char
    borderWidth*: int
    delta*: int
    sendEvent*: bool
    bindingPatterns*: int
    keysym*: Keysym
    property*: string
    root*: Widget
    subwindow*: Widget 
    `type`*: EventType
    widget*: Widget
    xRoot*, yRoot*: int

  TkCmdType* = TkWidgetCommand          or
               TkScaleCommand           or
               TkEntryCommand           or
               TkSelectionHandleCommand or
               TkGenericCommand         or
               TkEventCommand

var
  widgetCmdData: seq[TkWidgetCmdData[TkWidgetCommand]]
  scaleCmdData: seq[TkWidgetCmdData[TkScaleCommand]]
  eventCmdData: seq[TkWidgetCmdData[TkEntryCommand]]
  selectionHandleCmdData: seq[TkCmdData[TkSelectionHandleCommand]]
  genericCommandData: seq[TkCmdData[TkGenericCommand]]
  eventCommandData: seq[TkCmdData[TkEventCommand]]

proc toTclList(padding: int or float or string): string =
  $padding
proc toTclList(padding: tuple): string =
  "{$1 $2}" % [$padding[0], $padding[1]]
proc toTclList[T](arr: openArray[T]): string =
  '{' & arr.join(" ") & '}'

proc tkintwidgetcmd*(clientData: ClientData, _: ptr Interp, _: cint, _: cstringArray): cint {.cdecl.} =
  var data = cast[TkWidgetCmdData[TkWidgetCommand]](clientData)

  if data != nil:
    data.fun(data.widget, data.clientdata)

  return TCL_OK

proc tkintscalecmd*(clientData: ClientData, interp: ptr Interp, _: cint, argv: cstringArray): cint {.cdecl.} =
  let data = cast[TkWidgetCmdData[TkScaleCommand]](clientData)
  let args = argv.cstringArrayToSeq()

  if data.fun != nil:
    data.fun(data.widget, args[1].parseFloat(), data.clientdata)

  return TCL_OK

proc tkintselhandlecmd*(clientData: ClientData, interp: ptr Interp, _: cint, argv: cstringArray): cint {.cdecl.} =
  let data = cast[TkCmdData[TkSelectionHandleCommand]](clientData)
  let args = argv.cstringArrayToSeq()

  if data.fun != nil:
    interp.setResult cstring data.fun(args[1].parseInt(), args[2].parseInt(), data.clientdata)

  return TCL_OK

proc tkintgenericcmd*(clientData: ClientData, _: ptr Interp, _: cint, _: cstringArray): cint {.cdecl.} =
  let data = cast[TkCmdData[TkGenericCommand]](clientData)

  if data.fun != nil:
    data.fun(data.clientdata)

  return TCL_OK

template dontStress[T](op: T): T =
  var result: T

  try: result = op
  except ValueError: discard
  
  result

template newWidgetAttr(interp: ptr Interp, id: int): Widget =
  if id != 0:
    var result: Widget

    new result
    new result.tk
    
    interp.eval(cstring "winfo pathname " & $id)

    result.tk.interp = interp
    result.pathname = $interp.getStringResult()

    result
  else:
    nil

template newWidgetAttr(interp: ptr Interp, name: string): Widget =
  var result: Widget

  new result
  new result.tk

  result.tk.interp = interp
  result.pathname = name

  result

{.push warning[HoleEnumConv]: off.}

proc tkinteventcmd*(clientData: ClientData, interp: ptr Interp, _: cint, argv: cstringArray): cint {.cdecl.} =
  let data = cast[TkCmdData[TkEventCommand]](clientData)
  let args = argv.cstringArrayToSeq() # all except %K

  var event: Event

  event.serial = args[1].parseInt()

  if args[2] != "??":
    event.above = interp.newWidgetAttr(args[2].parseHexInt())

  event.button = args[3].parseInt().dontStress()
  event.count = args[4].parseInt().dontStress()
  event.userData = args[5]
  event.focus = args[6] == "1"
  event.height = args[7].parseInt().dontStress()

  if args[7] != "??":
    event.window = interp.newWidgetAttr(args[8].parseHexInt())

  event.keycode = args[9].parseInt().dontStress()
  event.mode = args[10]
  event.override = args[11] == "1"
  event.place = args[12]
  event.state =  args[13]
  event.time = args[14].parseInt().dontStress()
  event.width = args[15].parseInt().dontStress()
  event.x = args[16].parseInt().dontStress()
  event.y = args[17].parseInt().dontStress()
  #? unicode char
  event.borderWidth = args[19].parseInt().dontStress()
  event.delta = args[20].parseInt().dontStress()
  event.sendEvent = args[21] == "1"
  # keysym str -- ignored
  event.bindingPatterns = args[22].parseInt().dontStress()

  if args[23] != "??":
    event.keysym = Keysym(args[23].parseInt().dontStress())

  event.property = args[24]

  if args[25] != "??":
    event.root = interp.newWidgetAttr(args[25].parseHexInt())

  if args[26] != "??":
    event.subwindow = interp.newWidgetAttr(args[26].parseHexInt())

  event.`type` = parseEnum[EventType] args[27]
  if args[28] != "??":
    event.widget = interp.newWidgetAttr(args[28])

  event.xRoot = args[29].parseInt().dontStress()
  event.yRoot = args[30].parseInt().dontStress()

  if data.fun != nil:
    data.fun(event, data.clientdata)

  return TCL_OK

{.pop.}

proc tkintentrycmd*(clientData: ClientData, interp: ptr Interp, _: cint, argv: cstringArray): cint {.cdecl.} =
  let data = cast[TkWidgetCmdData[TkEntryCommand]](clientData)
  let args = argv.cstringArrayToSeq() # all except %K

  var event: EntryEvent

  event.actionType = parseInt args[1]
  event.charIndex = parseInt args[2]
  event.editedValue = args[3]
  event.currentValue = args[4]
  event.edit = args[5]
  event.validationMode = parseEnum[ValidationMode] args[6]
  event.validationTrigger = args[7]

  if data.fun != nil:
    let ret = data.fun(data.widget, event, data.clientdata)
    
    if ret: interp.setResult("1")
    else: interp.setResult("0")

  return TCL_OK

template registerCmdImpl(datatype: typedesc, dataseq: typed, intcmd: proc) {.dirty.} =
  let data = new datatype
  data.clientdata = clientdata1

  # dirty
  when datatype is TkWidgetCmdData:
    data.widget = w

  data.fun = cmd

  dataseq.add data

  # dirty
  tk.createCommand(name, cast[pointer](dataseq[^1]), intcmd)

proc registerCmd*(tk: Tk, w: Widget, clientdata1: pointer, name: string, cmd: TkCmdType) =
  when cmd is TkWidgetCommand:
    registerCmdImpl(TkWidgetCmdData[TkWidgetCommand], widgetCmdData, tkintwidgetcmd)

  elif cmd is TkSelectionHandleCommand:
    registerCmdImpl(TkCmdData[TkSelectionHandleCommand], selectionHandleCmdData, tkintselhandlecmd)

  elif cmd is TkGenericCommand:
    registerCmdImpl(TkCmdData[TkGenericCommand], genericCommandData, tkintgenericcmd)

  elif cmd is TkScaleCommand:
    registerCmdImpl(TkWidgetCmdData[TkScaleCommand], scaleCmdData, tkintscalecmd)

  elif cmd is TkEntryCommand:
    registerCmdImpl(TkWidgetCmdData[TkEntryCommand], eventCmdData, tkintentrycmd)

  else:
    registerCmdImpl(TkCmdData[TkEventCommand], eventCommandData, tkinteventcmd)

proc registerCmd*(tk: Tk, clientdata1: pointer, name: string, cmd: TkCmdType) =
  registerCmd(tk, nil, clientdata1, name, cmd)

proc `$`*(w: Widget): string = 
  if w != nil: w.pathname
  else: ""

proc `==`*(w1, w2: Widget): bool =
  if w1 == nil and w2 == nil: return true
  elif w1 == nil xor w2 == nil: return false
  else: w1.pathname == w2.pathname

proc newWidgetFromPathname*(tk: Tk, pathname: string): Widget =
  new result

  result.tk = tk
  result.pathname = pathname

proc pathName*(names: varargs[string]): string =
  result = names.join(".")

  if names[0] == ".":
    result = result[1..^1] # discard leading extra '.'

template configure*(w: Widget or typed, args: openArray[(string, string)]) =
  discard w.tk.call($w, "configure", args.toArgs())

template cget*(w: Widget or typed, option: string): string =
  w.tk.call($w, "cget", {option: " "}.toArgs())

proc destroy*(w: Widget) =
  ## Destroys a widget and its children
  
  w.tk.call("destroy", w)

# --- --- Geometry Managers

template bboxImpl(w: Widget) {.dirty.} =
  let nums = w.tk.result.split()

  result.offsetX = nums[0].parseInt()
  result.offsetY = nums[1].parseInt()
  result.width = nums[2].parseInt()
  result.height = nums[3].parseInt()

template infoImpl(w: Widget) {.dirty.} =
  let res = w.tk.result.split()

  for idx in 0..<res.len:
    if idx mod 2 != 0: continue

    result[res[idx][1..^1]] = res[idx + 1]

template slavesImpl(w: Widget) {.dirty.} =
  let res = w.tk.result

  for pathname in res.split():
    result.add newWidgetFromPathname(w.tk, pathname)

# --- pack

proc pack*[PX, PY: Padding](
  w: Widget,
  after: Widget = nil,
  anchor: AnchorPosition = AnchorPosition.Center,
  before: Widget = nil,
  expand: bool = false,
  fill: FillStyle = FillStyle.None,
  `in`: Widget = nil,
  ipadx: int or float or string = 0,
  ipady: int or float or string = 0,
  padx: PX = 0,
  pady: PY = 0,
  side: Side = Side.Top
) =

  w.tk.call(
    "pack configure",
    $w,
    {
      "after": $after,
      "anchor": $anchor,
      "before": $before,
      "expand": $expand,
      "fill": $fill,
      "in": $`in`,
      "ipadx": $ipadx,
      "ipady": $ipady,
      "padx": padx.toTclList(),
      "pady": pady.toTclList(),
      "side": $side
    }.toArgs()
  )

proc packForget*(w: Widget) =
  w.tk.call("pack forget", $w)

proc packSlaves*(w: Widget): seq[Widget] =
  w.tk.call("pack slaves", $w)

  w.slavesImpl()

proc packContent*(w: Widget): seq[Widget] =
  w.packSlaves()

proc packPropagate*(w: Widget, propagate: bool = true) =
  w.tk.call("pack propagate", $w, $propagate)

proc packInfo*(w: Widget): Table[string, string] =
  result = initTable[string, string]()

  w.infoImpl()

# --- place

proc place*(
  w: Widget,
  anchor: AnchorPosition = Northwest,
  bordermode: BorderMode = Inside,
  height: int or float or string,
  `in`: Widget = nil,
  relheight: float = 1,
  relwidth: float = 1,
  relx: float = 0,
  rely: float = 0,
  width: int or float or string,
  x: string or float,
  y: string or float
) =

  w.tk.call(
    "place configure",
    w,
    {
      "anchor": $anchor,
      "bordermode": $bordermode,
      "height": $height,
      "in": $`in`,
      "relheight": $relheight,
      "relwidth": $relwidth,
      "relx": $relx,
      "rely": $rely,
      "width": $width,
      "x": $x,
      "y": $y
    }.toArgs()
  )

proc placeForget*(w: Widget) =
  w.tk.call("place forget", $w)

proc placeSlaves*(w: Widget): seq[Widget] =
  w.tk.call("place slaves", $w)

  w.slavesImpl()

proc placeContent*(w: Widget): seq[Widget] =
  w.placeSlaves()

proc placePropagate*(w: Widget, propagate: bool = true) =
  w.tk.call("place propagate", $w, $propagate)

proc placeInfo*(w: Widget): Table[string, string] =
  result = initTable[string, string]()

  w.infoImpl()

# --- grid

# two seperate PX and PY generics do not force them to be the same type
proc grid*[PX, PY: Padding](
  w: Widget,
  column: string or int = "",
  row: string or int = "",
  columnspan: string or int = "",
  rowspan: string or int = "",
  `in`: Widget = nil,
  ipadx: float = 0,
  ipady: float = 0,
  padx: PX = 0,
  pady: PY = 0,
  sticky: FillStyle or AnchorPosition or string = ""
) =
  w.tk.call(
    "grid configure",
    w,
    {
      "column": $column,
      "columnspan": $columnspan,
      "in": $`in`,
      "ipadx": $ipadx,
      "ipady": $ipady,
      "padx": padx.toTclList(),
      "pady": pady.toTclList(),
      "row": $row,
      "rowspan": $rowspan,
      "sticky": $sticky
    }.toArgs
  )

proc gridAnchor*(w: Widget, anchor: AnchorPosition = Northwest) =
  w.tk.call("grid anchor", w, anchor)

proc gridBbox*(w: Widget): tuple[offsetX, offsetY, width, height: int] =
  w.tk.call("grid bbox", w)
  w.bboxImpl()

proc gridBbox*(w: Widget, col, row: int): tuple[offsetX, offsetY, width, height: int] =
  w.tk.call("grid bbox", w, col, row)
  w.bboxImpl()

proc gridBbox*(w: Widget, col, row, col2, row2: int): tuple[offsetX, offsetY, width, height: int] =
  w.tk.call("grid bbox", w, col, row, col2, row2)
  w.bboxImpl()

proc gridForget*(w: Widget) =
  w.tk.call("grid forget", $w)

proc gridInfo*(w: Widget): Table[string, string] =
  result = initTable[string, string]()
  w.tk.call("grid info", w)
  w.infoImpl()

proc gridLocation*(w: Widget, x, y: int): seq[int] =
  w.tk.call("grid bbox", w, x, y)

  let nums = w.tk.result.split()

  if nums.len < 1:
    return @[0]

  result[0] = nums[0].parseInt()
  result[1] = nums[1].parseInt()

proc gridSlaves*(w: Widget): seq[Widget] =
  w.tk.call("grid slaves", $w)
  w.slavesImpl()

proc gridSlaves*(w: Widget, col: int): seq[Widget] =
  w.tk.call("grid slaves", $w, {"col": $col}.toArgs())
  w.slavesImpl()

proc gridSlaves*(w: Widget, row: int): seq[Widget] =
  w.tk.call("grid slaves", $w, {"row": $row}.toArgs())
  w.slavesImpl()

proc gridContent*(w: Widget): seq[Widget] =
  w.gridSlaves()

proc gridContent*(w: Widget, col: int): seq[Widget] =
  w.gridSlaves(col=col)

proc gridContent*(w: Widget, row: int): seq[Widget] =
  w.gridSlaves(row=row)

proc gridPropagate*(w: Widget, propagate: bool) =
  w.tk.call("grid propagate", w, propagate)

proc gridPropagate*(w: Widget): bool =
  w.tk.call("grid propagate", w) == "1"

proc gridRemove*(w: Widget) =
  w.tk.call("grid remove", w)

proc gridSize*(w: Widget): tuple[cols, rows: int] =
  w.tk.call("grid size", w)

  let nums = w.tk.result.split()

  result.cols = nums[0].parseInt()
  result.rows = nums[1].parseInt()

#! row configure
#! column configure

# --- busy

proc busy*(w: Widget, cursorName: string = "") =
  w.tk.call(
    "tk busy hold",
    w,
    {"cursor": cursorName}.toArgs()
  )

proc busyCget*(w: Widget): string =
  w.tk.call("tk busy cget", w, "-cursor")
  w.tk.result

proc busyConfigure*(w: Widget, cursorName: string or Cursor) =
  w.tk.call("tk busy configure", w, {"cursor": tclEscape $cursorName}.toArgs())

proc busyConfigure*(w: Widget): seq[string] =
  w.tk.call("tk busy configure", w)[1..^2].split()[3..^1]

proc busyForget*(w: Widget) =
  w.tk.call("tk busy forget", w)

proc busyCurrent*(w: Widget, pattern: string = ""): seq[Widget] =
  w.tk.call("tk busy current", w, {"pattern": pattern}.toArgs)

  w.slavesImpl()

proc busyStatus*(w: Widget): bool =
  w.tk.call("tk busy status", w) == "1"

# --- appname

proc appname*(tk: Tk, appname: string) {.alias: "appname=".} =
  tk.call("tk appname", tclEscape appname)

proc appname*(tk: Tk): string =
  tk.call("tk appname")
  tk.result

# --- tk_version & tk_patchLevel

proc version*(tk: Tk): string =
  tk.call("set tk_version")

proc patchLevel*(tk: Tk): string =
  tk.call("set tk_patchLevel")

# --- inactive

proc inactive*(w: Widget): int =
  parseInt w.tk.call("tk inactive", {"displayof": $w}.toArgs)

proc inactiveReset*(w: Widget) =
  w.tk.call("tk inactive", {"displayof": $w}.toArgs, "reset")

# --- scaling

proc scaling*(w: Widget, number: float) {.alias: "scaling=".} =
  w.tk.call("tk scaling", {"displayof": $w}.toArgs, number)

proc scaling*(w: Widget): float =
  parseFloat w.tk.call("tk scaling", {"displayof": $w}.toArgs)

# --- fontchooser 

# TODO fontchooser 

# --- useinputmethods

proc useinputmethods*(w: Widget, useinputmethods: bool) {.alias: "useinputmethods=".} =
  w.tk.call("tk useinputmethods", {"displayof": $w}.toArgs, useinputmethods)

proc useinputmethods*(w: Widget): bool =
  w.tk.call("tk useinputmethods", {"displayof": $w}.toArgs) == "1"

# --- windowingsystem

proc windowingsystem*(tk: Tk): string =
  tk.call("tk windowingsystem")
  tk.result

# --- tk_chooseDirectory

# two options were omitted here:
# -command
# -message
#
# These options are only available on Mac OS X

proc chooseDirectory*(
  w: Widget = nil,
  parent: Widget = w,
  initialdir: string = "",
  mustexist: bool = false,
  title: string = ""
): string =
  w.tk.call(
    "tk_chooseDirectory",
    {
      "parent": $parent,
      "initialdir": tclEscape initialdir,
      "mustexist": $mustexist,
      "title": tclEscape title,
    }.toArgs()
  )

# --- tk_chooseColor

proc chooseColor*(
  w: Widget = nil,
  parent: Widget = w,
  initialColor: Color = 0.Color,
  title: string = ""
): Color =
  w.tk.call(
    "tk_chooseColor",
    {
      "parent": $parent,
      "initialcolor": $initialColor,
      "title": tclEscape title,
    }.toArgs()
  ).parseColor()

# --- tk_focus*

proc focusNext*(w: Widget): Widget =
  w.tk.call("tk_focusNext", w)

  if w.tk.result.len == 0:
    return nil

  return newWidgetFromPathname(w.tk, w.tk.result)

proc focusPrev*(w: Widget): Widget =
  w.tk.call("tk_focusPrev", w)

  if w.tk.result.len == 0:
    return nil

  return newWidgetFromPathname(w.tk, w.tk.result)

proc focusFollowsMouse*(tk: Tk) =
  tk.call("tk_focusFollowsMouse")

# --- focus

proc focus*(tk: Tk): Widget =
  tk.call("focus")
  tk.newWidgetFromPathname(tk.result)

proc focus*(w: Widget, force: bool = false) =
  let forceArg = if force == false: "" else: " "

  w.tk.call("focus", {"force": forceArg}.toArgs, w)

proc focusDisplayof*(w: Widget): Widget =
  w.tk.call("focus", {"displayof": $w}.toArgs)
  w.tk.newWidgetFromPathname(w.tk.result)

proc focusLastfor*(w: Widget): Widget =
  w.tk.call("focus", {"lastfor": $w}.toArgs)
  w.tk.newWidgetFromPathname(w.tk.result)

# --- tk_getOpenFile, tk_getSaveFile

template getFileImpl(cmd: string): string {.dirty.} =
  var filetypesList: seq[string]

  for filetype in filetypes:
    filetypesList.add "{{$1} {$2} {$3}}" % [filetype.typeName, filetype.extentions.join(" "), filetype.macTypes.join(" ")]

  when cmd == "tk_getOpenFile":
    let confirmoverwrite = ""

  when cmd == "tk_getSaveFile":
    let multiple = ""

  w.tk.call(
    cmd,
    {
      "confirmoverwrite": $confirmoverwrite,
      "defaultextension": $defaultextension,
      "filetypes": filetypesList.toTclList(),
      "initialdir": tclEscape initialdir,
      "initialfile": tclEscape initialfile,
      "multiple": $multiple,
      "parent": $parent,
      "title": tclEscape title,
      "typevariable": $typevariable
    }.toArgs()
  )

proc getOpenFile*(
  w: Widget,
  defaultextension: string = "",
  filetypes: openArray[tuple[typeName: string, extentions, macTypes: seq[string]]] = @[], # seq because openArray is an "invalid type"
  initialdir: string = "",
  initialfile: string = "",
  multiple: bool = false,
  parent: Widget = w,
  title: string = "",
  typevariable: TkVar = nil
): string =
  getFileImpl("tk_getOpenFile")

proc getSaveFile*(
  w: Widget,
  confirmoverwrite: bool = true,
  defaultextension: string = "",
  filetypes: openArray[tuple[typeName: string, extentions, macTypes: seq[string]]] = @[], # seq because openArray is an "invalid type"
  initialdir: string = "",
  initialfile: string = "",
  parent: Widget = w,
  title: string = "",
  typevariable: TkVar = nil
): string =
  getFileImpl("tk_getSaveFile")

# --- tk_messageBox

proc messageBox*(
  w: Widget,
  message: string = "",
  `type`: MessageBoxType = Ok,
  detail: string = "",
  default: ButtonName = Default,
  icon: IconImage = Info,
  parent: Widget = w,
  title: string = "",
): ButtonName =
  parseEnum[ButtonName] w.tk.call(
    "tk_messageBox",
    {
      "default": $default,
      "detail": tclEscape detail,
      "icon": $icon,
      "message": tclEscape message,
      "parent": $parent,
      "title": tclEscape title,
      "type": $`type`
    }.toArgs
  )

# --- lower & raise

proc lower*(w: Widget, belowThis: Widget = nil) =
  w.tk.call("lower", w, belowThis)

proc `raise`*(w: Widget, aboveThis: Widget = nil) =
  w.tk.call("raise", w, aboveThis)

# --- tk_setPalette & tk_bisque & ona poka

proc setPalette*(tk: Tk, options: openArray[tuple[name: string, value: Color]]) =
  var opts: seq[string]

  for option in options:
    opts.add option[0]
    opts.add tclEscape $option[1]

  tk.call("tk_setPalette", opts.join(" "))

proc setPalette*(tk: Tk, backgroundColor: Color) =
  tk.call("tk_setPalette", backgroundColor)

proc bisque*(tk: Tk) =
  tk.call("tk_bisque")

proc strictMotif*(tk: Tk, motif: bool = true) =
  tk.call("set", "tk_strictMotif", motif)

# --- grab

proc grab*(w: Widget, global: bool = false) =
  let argGlobal = if global == false: "" else: " "

  w.tk.call("grab set", {"global": argGlobal}.toArgs, w)

proc grabRelease*(w: Widget) =
  w.tk.call("grab release",  w)

proc grabStatus*(w: Widget): string =
  w.tk.call("grab status", w)

proc grabCurrent*(w: Widget): Widget =
  w.tk.call("grab current", w)
  
  if w.tk.result.len == 0:
    return nil

  return w.tk.newWidgetFromPathname(w.tk.result)

proc grabCurrent*(tk: Tk): seq[Widget] =
  tk.call("grab current")
  
  if tk.result.len == 0:
    return @[]

  for pathname in tk.result.split():
    result.add tk.newWidgetFromPathname(pathname)

# --- bell

proc bell*(w: Widget, nice: bool = false) {.alias: "ring".} =
  let argNice = if nice == false: "" else: " "

  w.tk.call("bell", {"displayof": $w, "nice": $argNice}.toArgs)

# --- send

proc send*(w: Widget, async: bool, cmd: string, args: varargs[string]) =
  let asyncarg =
    if async: " "
    else: ""

  w.tk.call("send", {"displayof": $w, "async": asyncarg}, cmd & ' ' & args.join(" "))

# --- bind

proc `bind`*(w: Widget, sequence: string, clientdata: pointer = nil, command: TkEventCommand) =
  let name = genName("event_command_" & sequence & "_")

  w.tk.registerCmd(nil, repr name, command)

  w.tk.call(
    "bind",
    w,
    repr sequence,
    "{$1 %# %a %b %c %d %f %h %i %k %m %o %p %s %t %w %x %y %A %B %D %E %M %N %P %R %S %T %W %X %Y}" % name
  )

proc `bind`*(tk: Tk, className: string, sequence: string, clientdata: pointer = nil, command: TkEventCommand) =
  let name = genName("event_command_" & className & "_")

  tk.registerCmd(nil, name, command)

  tk.call(
    "bind",
    repr className,
    repr sequence,
    "{$1 %# %a %b %c %d %f %h %i %k %m %o %p %s %t %w %x %y %A %B %D %E %M %N %P %R %S %T %W %X %Y}" % name
  )

proc bindAll*(tk: Tk, sequence: string, clientdata: pointer = nil, command: TkEventCommand) =
  let name = genName("event_command_ALL_")

  tk.registerCmd(nil, name, command)

  tk.call(
    "bind",
    "all",
    repr sequence,
    "{$1 %# %a %b %c %d %f %h %i %k %m %o %p %s %t %w %x %y %A %B %D %E %M %N %P %R %S %T %W %X %Y}" % name
  )

# --- bindtags

proc bindtags*(w: Widget, tagList: varargs[string, `$`]) = 
  w.tk.call("bindtags", w, tagList.toTclList())

proc bindtags*(w: Widget): seq[string] =
  w.tk.call("bindtags", w).split(" ")

# --- event

proc eventAdd*(tk: Tk, virtual: string, sequence: varargs[string]) =
  tk.call("event add", repr virtual, sequence.join(" "))

proc eventDelete*(tk: Tk, virtual: string, sequence: varargs[string] = "") =
  tk.call("event delete", repr virtual, sequence.join(" "))

proc eventGenerate*(
  tk: Tk,
  w: Widget,
  event: string,
  eventObj: Event,
  warp: bool = false
) =
  tk.call(
    "event generate",
    tclEscape $w,
    event,
    {
      "above": repr $eventObj.above,
      "borderwidth": repr $eventObj.borderwidth,
      "button": repr $eventObj.button,
      "count": repr $eventObj.count,
      "data": repr $eventObj.userData, # userdata
      "delta": repr $eventObj.delta,
      "detail": repr $eventObj.userData, # detail
      "focus": repr $eventObj.focus,
      "height": repr $eventObj.height,
      "keycode": repr $eventObj.keycode,
      "keysym": repr $eventObj.keysym,
      "mode": repr $eventObj.mode,
      "override": repr $eventObj.override,
      "place": repr $eventObj.place,
      "root": repr $eventObj.root,
      "rootx": repr $eventObj.xRoot,
      "rooty": repr $eventObj.yRoot,
      "sendevent": repr $eventObj.sendevent,
      "serial": repr $eventObj.serial,
      "state": repr $eventObj.state,
      "subwindow": repr $eventObj.subwindow,
      "time": repr $eventObj.time,
      "warp": $warp,
      "width": repr $eventObj.width,
      "when": repr $eventObj.time,
      "x": repr $eventObj.x
    }.toArgs()
  )

proc eventInfo*(tk: Tk): seq[string] =
  tk.call("event info").split(' ')

proc eventInfo*(tk: Tk, virtual: string): seq[string] =
  tk.call("event info", repr virtual).split(' ')

# --- tk_text*

proc textCopy*(w: Widget) = w.tk.call("tk_textCopy", w)
proc textCut*(w: Widget) = w.tk.call("tk_textCut", w)
proc textPaste*(w: Widget) = w.tk.call("tk_textPaste", w)

# --- clipboard

proc clipboardAdd*(w: Widget, data: string; format = "STRING", `type`: string = "STRING") =
  w.tk.call(
    "clipboard append",
    {"displayof": $w, "format": format, "type": `type`}.toArgs,
    "--",
    tclEscape data
  )

proc clipboardClear*(w: Widget) =
  w.tk.call("clipboard clear", {"displayof": $w}.toArgs)

proc clipboardGet*(w: Widget, `type`: string = "UTF8_STRING"): string =
  w.tk.call("clipboard get", {"displayof": $w, "type": `type`}.toArgs)

# --- selection

proc selectionClear*(w: Widget, selection: string = "PRIMARY") =
  w.tk.call("selection clear", {"displayof": $w, "selection": selection}.toArgs)

proc selectionGet*(w: Widget, selection = "PRIMARY", `type`: string = "UTF8_STRING"): string =
  w.tk.call("selection get", {"displayof": $w, "selection": selection, "type": `type`}.toArgs)

proc selectionHandle*(w: Widget, selection = "PRIMARY", `type`: string = "UTF8_STRING", format: string = "STRING", clientdata: pointer = nil, command: TkSelectionHandleCommand) =
  var cmdname: string

  if command != nil:
    cmdname = genName("selection_handle_command_")
    w.tk.registerCmd(nil, cmdname, command)
  else:
    cmdname = tclEscape ""
  
  w.tk.call("selection handle", {"selection": selection, "type": `type`}.toArgs, w, cmdname)

proc selectionOwn*(w: Widget, selection: string = "PRIMARY"): Widget =
  w.tk.call("selection own", {"selection": selection}.toArgs)

  if w.tk.result.len == 0:
    return nil

  return w.tk.newWidgetFromPathname(w.tk.result)

proc selectionOwn*(w: Widget, selection: string = "PRIMARY", clientdata: pointer = nil, command: TkGenericCommand) =
  var cmdname: string

  if command != nil:
    cmdname = genName("selection_own_command_")
    w.tk.registerCmd(nil, cmdname, command)
  else:
    cmdname = ""

  w.tk.call("selection own", {"command": cmdname, "selection": selection}.toArgs, w)

# --- tkwait

proc wait*(tkvar: TkVar) =
  tkvar.tk.call("tkwait variable", tkvar.varname)

proc waitVisibility*(w: Widget) =
  w.tk.call("tkwait visiblity", w)

proc waitWindow*(w: Widget) =
  w.tk.call("tkwait window", w)

# --- --- Common widget options

proc `activebackground=`*(w: Widget, activebackground: Color)                         = w.configure({"activebackground": $activebackground})
proc `activeborderwidth=`*(w: Widget, activeborderwidth: string or float or int)      = w.configure({"activeborderwidth": $activeborderwidth})
proc `activeforeground=`*(w: Widget, activeforeground: Color)                         = w.configure({"activeforeground": $activeforeground})
proc `anchor=`*(w: Widget, anchor: AnchorPosition)                                    = w.configure({"anchor": $anchor})
proc `background=`*(w: Widget, background: Color) {.alias: "bg=".}                    = w.configure({"background": $background})
proc `borderwidth=`*(w: Widget, borderwidth: string or float or int) {.alias: "bd=".} = w.configure({"borderwidth": $borderwidth})
proc `cursor=`*(w: Widget, cursor: Cursor)                                            = w.configure({"cursor": $cursor})
proc `compound=`*(w: Widget, compound: WidgetCompound)                                = w.configure({"compound": $compound})
proc `disabledforeground=`*(w: Widget, disabledforeground: Color or string)           = w.configure({"disabledforeground": repr $disabledforeground})
proc `disabledbackground=`*(w: Widget, disabledbackground: Color or string)           = w.configure({"disabledbackground": repr $disabledbackground})
proc `exportselection=`*(w: Widget, exportselection: bool)                            = w.configure({"exportselection": $exportselection})
#    proc `font=`*(w: Widget, font)                                                   = w.configure({"font": $font})
proc `foreground=`*(w: Widget, foreground: Color) {.alias: "fg=".}                    = w.configure({"foreground": $foreground})
# proc `height=`*(w: Widget, height: string or float or int)                            = w.configure({"height": $height})
proc `highlightbackground=`*(w: Widget, highlightbackground: Color)                   = w.configure({"highlightbackground": $highlightbackground})
proc `highlightcolor=`*(w: Widget, highlightcolor: Color)                             = w.configure({"highlightcolor": $highlightcolor})
proc `highlightthickness=`*(w: Widget, highlightthickness: string or float or int)    = w.configure({"highlightthickness": $highlightthickness})
#    proc `image=`*(w: Widget, image)                                                 = w.configure({"image": $image})
proc `insertbackground=`*(w: Widget, insertbackground: Color)                         = w.configure({"insertbackground": $insertbackground})
proc `insertborderwidth=`*(w: Widget, insertborderwidth: string or float or int)      = w.configure({"insertborderwidth": $insertborderwidth})
proc `insertofftime=`*(w: Widget, insertofftime: int)                                 = w.configure({"insertofftime": $insertofftime})
proc `insertontime=`*(w: Widget, insertontime: int)                                   = w.configure({"insertontime": $insertontime})
proc `insertwidth=`*(w: Widget, insertwidth: int or float or string)                  = w.configure({"insertwidth": $insertwidth})
proc `jump=`*(w: Widget, jump: bool)                                                  = w.configure({"jump": $jump})
proc `justify=`*(w: Widget, justify: TextJustify)                                     = w.configure({"justify": $justify})
proc `orient=`*(w: Widget, orient: WidgetOrientation)                                 = w.configure({"orient": $orient})
proc `padx=`*(w: Widget, padx: string or float or int)                                = w.configure({"padx": $padx})
proc `pady=`*(w: Widget, pady: string or float or int)                                = w.configure({"pady": $pady})
proc `relief=`*(w: Widget, relief: WidgetRelief)                                      = w.configure({"relief": $relief})
proc `repeatdelay=`*(w: Widget, repeatdelay: float)                                   = w.configure({"repeatdelay": $repeatdelay})
proc `repeatinterval=`*(w: Widget, repeatinterval: float)                             = w.configure({"repeatinterval": $repeatinterval})
proc `selectbackground=`*(w: Widget, selectbackground: Color)                         = w.configure({"selectbackground": $selectbackground})
proc `selectborderwidth=`*(w: Widget, selectborderwidth: string or float or int)      = w.configure({"selectborderwidth": $selectborderwidth})
proc `selectforeground=`*(w: Widget, selectforeground: Color)                         = w.configure({"selectforeground": $selectforeground})
proc `setgrid=`*(w: Widget, setgrid: bool)                                            = w.configure({"setgrid": $setgrid})
proc `takefocus=`*(w: Widget, takefocus: bool or string)                              = w.configure({"takefocus": $takefocus})
proc `text=`*(w: Widget, text: string)                                                = w.configure({"text": tclEscape text})
proc `textvariable=`*(w: Widget, textvariable: TkString)                              = w.configure({"textvariable": textvariable.varname})
proc `troughcolor=`*(w: Widget, troughcolor: Color)                                   = w.configure({"troughcolor": $troughcolor})
proc `underline=`*(w: Widget, underline: int)                                         = w.configure({"underline": $underline})
# proc `width=`*(w: Widget, width: string or float or int)                              = w.configure({"width": $width})
proc `wraplength=`*(w: Widget, wraplength: int)                                       = w.configure({"wraplength": $wraplength})
proc `xscrollcommand=`*(w: Widget, xscrollcommand: string)                            = w.configure({"xscrollcommand": repr $xscrollcommand})
proc `yscrollcommand=`*(w: Widget, yscrollcommand: string)                            = w.configure({"yscrollcommand": repr $yscrollcommand})

proc activebackground*(w: Widget): Color             = parseColor w.cget("activebackground")
proc activeborderwidth*(w: Widget): string           = w.cget("activeborderwidth")
proc activeforeground*(w: Widget): Color             = parseColor w.cget("activeforeground")
proc anchor*(w: Widget): AnchorPosition              = parseEnum[AnchorPosition] w.cget("anchor")
proc background*(w: Widget): Color {.alias: "bg".}   = parseColor w.cget("background")
proc borderwidth*(w: Widget): string {.alias: "bd".} = w.cget("borderwidth")
proc cursor*(w: Widget): Cursor                      = parseEnum[Cursor] w.cget("cursor")
proc compound*(w: Widget): WidgetCompound            = parseEnum[WidgetCompound] w.cget("compound")
proc disabledforeground*(w: Widget): Color           = parseColor w.cget("disabledforeground")
proc disabledbackground*(w: Widget): Color           = parseColor w.cget("disabledbackground")
proc exportselection*(w: Widget): bool               = w.cget("exportselection") == "1"
#    proc font*(w: Widget)                           = w.cget("font")
proc foreground*(w: Widget): Color {.alias: "fg".}   = parseColor w.cget("foreground")
# proc height*(w: Widget): string                      = w.cget("height")
proc highlightbackground*(w: Widget): Color          = parseColor w.cget("highlightbackground")
proc highlightcolor*(w: Widget): Color               = parseColor w.cget("highlightcolor")
proc highlightthickness*(w: Widget): string          = w.cget("highlightthickness")
#    proc image*(w: Widget)                          = w.cget("image")
proc insertbackground*(w: Widget): Color             = parseColor w.cget("insertbackground")
proc insertborderwidth*(w: Widget): string           = w.cget("insertborderwidth")
proc insertofftime*(w: Widget): int                  = parseInt w.cget("insertofftime")
proc insertontime*(w: Widget): int                   = parseInt w.cget("insertontime")
proc insertwidth*(w: Widget): string                 = w.cget("insertwidth")
proc jump*(w: Widget): bool                          = w.cget("jump") == "1"
proc justify*(w: Widget): TextJustify                = parseEnum[TextJustify] w.cget("justify")
proc orient*(w: Widget): WidgetOrientation           = parseEnum[WidgetOrientation] w.cget("orient")
proc padx*(w: Widget): string                        = w.cget("padx")
proc pady*(w: Widget): string                        = w.cget("pady")
proc relief*(w: Widget): WidgetRelief                = parseEnum[WidgetRelief] w.cget("relief")
proc repeatdelay*(w: Widget): float                  = parseFloat w.cget("repeatdelay")
proc repeatinterval*(w: Widget): float               = parseFloat w.cget("repeatinterval")
proc selectbackground*(w: Widget): Color             = parseColor w.cget("selectbackground")
proc selectborderwidth*(w: Widget): string           = w.cget("selectborderwidth")
proc selectforeground*(w: Widget): Color             = parseColor w.cget("selectforeground")
proc setgrid*(w: Widget): bool                       = w.cget("setgrid") == "1"
proc takefocus*(w: Widget): string                   = w.cget("takefocus")
proc text*(w: Widget): string                        = w.cget("text")
proc textvariable*(w: Widget): TkVar                 = createTkVar w.tk, w.cget("textvariable")
proc troughcolor*(w: Widget): Color                  = parseColor w.cget("troughcolor")
proc underline*(w: Widget): int                      = parseInt w.cget("underline")
# proc width*(w: Widget): string                       = w.cget("width")
proc wraplength*(w: Widget): int                     = parseInt w.cget("wraplength")
proc xscrollcommand*(w: Widget): string              = w.cget("xscrollcommand")
proc yscrollcommand*(w: Widget): string              = w.cget("yscrollcommand")

