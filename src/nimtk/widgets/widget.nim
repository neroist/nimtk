import std/strutils
import std/sequtils
import std/tables
import std/colors
import std/times

import nimtcl except Time

import ../private/escaping
import ../private/tcllist
import ../private/toargs
import ../private/alias
import ../variables
import ../../nimtk

export variables

type
  Widget* = ref object of RootObj
    pathname*: string
    tk*: Tk
  
  TkWidgetCommand* = proc (widget: Widget)
  TkSelectionHandleCommand* = proc (offset, maxChars: int): string
  TkGenericCommand* = proc ()
  TkEventCommand* = proc (event: Event)
  TkScaleCommand* = proc (widget: Widget, newvalue: float)
  TkEntryCommand* = proc (widget: Widget, event: EntryEvent): bool
  TkSpinboxCommand* = proc (widget: Widget, button: string)
  
  TkCmdData[CMD] = ref object of RootObj
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
               TkSpinboxCommand         or
               TkSelectionHandleCommand or
               TkGenericCommand         or
               TkEventCommand

var
  widgetCmdData: seq[TkWidgetCmdData[TkWidgetCommand]]
  scaleCmdData: seq[TkWidgetCmdData[TkScaleCommand]]
  entryCmdData: seq[TkWidgetCmdData[TkEntryCommand]]
  selectionHandleCmdData: seq[TkCmdData[TkSelectionHandleCommand]]
  genericCmdData: seq[TkCmdData[TkGenericCommand]]
  eventCmdData: seq[TkCmdData[TkEventCommand]]
  spinboxCmdData: seq[TkCmdData[TkSpinboxCommand]]

proc tkintwidgetcmd*(clientData: ClientData, _: ptr Interp, _: cint, _: cstringArray): cint {.cdecl.} =
  var data = cast[TkWidgetCmdData[TkWidgetCommand]](clientData)

  if data != nil:
    data.fun(data.widget)

  return TCL_OK

proc tkintscalecmd*(clientData: ClientData, interp: ptr Interp, _: cint, argv: cstringArray): cint {.cdecl.} =
  let data = cast[TkWidgetCmdData[TkScaleCommand]](clientData)
  let args = argv.cstringArrayToSeq()

  if data.fun != nil:
    data.fun(data.widget, args[1].parseFloat())

  return TCL_OK

proc tkintselhandlecmd*(clientData: ClientData, interp: ptr Interp, _: cint, argv: cstringArray): cint {.cdecl.} =
  let data = cast[TkCmdData[TkSelectionHandleCommand]](clientData)
  let args = argv.cstringArrayToSeq()

  if data.fun != nil:
    interp.setResult cstring data.fun(args[1].parseInt(), args[2].parseInt())

  return TCL_OK

proc tkintgenericcmd*(clientData: ClientData, _: ptr Interp, _: cint, _: cstringArray): cint {.cdecl.} =
  let data = cast[TkCmdData[TkGenericCommand]](clientData)

  if data.fun != nil:
    data.fun()

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

  event.`type` = EventType parseInt args[27]
  if args[28] != "??":
    event.widget = interp.newWidgetAttr(args[28])

  event.xRoot = args[29].parseInt().dontStress()
  event.yRoot = args[30].parseInt().dontStress()

  if data.fun != nil:
    data.fun(event)

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
    let ret = data.fun(data.widget, event)
    
    if ret: interp.setResult("1")
    else: interp.setResult("0")

  return TCL_OK

proc tkintspinboxcmd*(clientData: ClientData, interp: ptr Interp, _: cint, argv: cstringArray): cint {.cdecl.} =
  let data = cast[TkWidgetCmdData[TkSpinboxCommand]](clientData)
  let args = argv.cstringArrayToSeq() # all except %K

  if data.fun != nil:
    data.fun(data.widget, args[1])

  return TCL_OK

template registerCmdImpl(datatype: typedesc, dataseq: typed, intcmd: proc) {.dirty.} =
  let data = new datatype

  # dirty
  when datatype is TkWidgetCmdData:
    data.widget = w

  data.fun = cmd

  dataseq.add data

  # dirty
  tk.createCommand(name, cast[pointer](dataseq[^1]), intcmd)

proc registerCmd*(tk: Tk, w: Widget, name: string, cmd: TkCmdType) =
  when cmd is TkWidgetCommand:
    registerCmdImpl(TkWidgetCmdData[TkWidgetCommand], widgetCmdData, tkintwidgetcmd)

  elif cmd is TkSelectionHandleCommand:
    registerCmdImpl(TkCmdData[TkSelectionHandleCommand], selectionHandleCmdData, tkintselhandlecmd)

  elif cmd is TkGenericCommand:
    registerCmdImpl(TkCmdData[TkGenericCommand], genericCmdData, tkintgenericcmd)

  elif cmd is TkScaleCommand:
    registerCmdImpl(TkWidgetCmdData[TkScaleCommand], scaleCmdData, tkintscalecmd)

  elif cmd is TkEntryCommand:
    registerCmdImpl(TkWidgetCmdData[TkEntryCommand], entryCmdData, tkintentrycmd)

  elif cmd is TkSpinboxCommand:
    registerCmdImpl(TkWidgetCmdData[TkSpinboxCommand], spinboxCmdData, tkintspinboxcmd)
  
  else:
    registerCmdImpl(TkCmdData[TkEventCommand], eventCmdData, tkinteventcmd)

proc registerCmd*(tk: Tk, name: string, cmd: TkCmdType) =
  registerCmd(tk, nil, name, cmd)

proc `$`*(w: Widget): string = 
  if w != nil: w.pathname
  else: ""

proc `==`*(w1, w2: Widget): bool =
  if w1.isNil() and w2.isNil(): return true
  elif w1.isNil() xor w2.isNil(): return false
  
  return w1.pathname == w2.pathname

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

# --- helpers

proc fromTclColor*[W](w: W, tclColor: string): Color =
  ## Get `colors.Color` from color string returned from Tk
  ## 
  ## This is needed if Tk returns, for example, "systemDefault" from a command,
  ## which cannot be parsed via just `parseColor`
  ##
  ## For all colors returned from Tk, please use this proc and not `parseColor`.

  # if the color is already a normal HTML code color...
  if tclColor[0] == '#':
    return parseColor tclColor

  # else, use winfo to get the exact 16-bit rgb values
  let rgb = w.tk.call("winfo", w, tclEscape tclColor)
    .split(' ')
    .map(parseInt)
  
  # the values returned are 16-bit, so we shift them right by 8 bits
  # to get the 8 bit value we need for `colors.rgb`
  return colors.rgb(
    (rgb[0] shr 8).clamp(0, 255),
    (rgb[1] shr 8).clamp(0, 255),
    (rgb[2] shr 8).clamp(0, 255)
  )

# --- --- Geometry Managers

template bboxImpl(w: Widget) {.dirty.} =
  let nums = w.tk.result.split()

  result.offsetX = nums[0].parseInt()
  result.offsetY = nums[1].parseInt()
  result.width = nums[2].parseInt()
  result.height = nums[3].parseInt()

template infoImpl(w: Widget) {.dirty.} =
  let res = w.tk.result.split()

  echo res

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
  anchor: AnchorPosition or string = "",
  before: Widget = nil,
  expand: bool or string = "",
  fill: FillStyle or string = "",
  `in`: Widget = nil,
  ipadx: int or float or string = 0,
  ipady: int or float or string = 0,
  padx: PX = "",
  pady: PY = "",
  side: Side or string = ""
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

template packContent*(w: Widget): seq[Widget] =
  w.packSlaves()

proc packPropagate*(w: Widget, propagate: bool = true) =
  w.tk.call("pack propagate", $w, $propagate)

proc packInfo*(w: Widget): Table[string, string] =
  result = initTable[string, string]()

  w.tk.call("pack info", w)

  w.infoImpl()

# --- place

proc place*(
  w: Widget,
  x: float or int or string = "",
  y: float or int or string = "",
  anchor: AnchorPosition or string = "",
  bordermode: BorderMode or string = "",
  height: int or float or string = "",
  `in`: Widget = nil,
  relheight: float or string = "",
  relwidth: float or string = "",
  relx: float or string = "",
  rely: float or string = "",
  width: int or float or string = ""
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

  w.tk.call("place info", w)

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
  ipadx: float or string = "",
  ipady: float or string = "",
  padx: PX = "",
  pady: PY = "",
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

proc gridColumnconfigure*(
  w: Widget,
  index: int or string or openArray[int],
  minsize: int or string = "",
  weight: int or string = "",
  uniform: bool or string = "",
  pad: int or string = "" 
) =
  w.tk.call(
    "grid columnconfigure",
    w,
    index.toTclList(),
    {
      "index": index,
      "minsize": minsize,
      "weight": weight,
      "uniform": uniform,
      "pad": pad
    }.toArgs()
  )

proc gridRowconfigure*(
  w: Widget,
  index: int or string = "",
  minsize: int or string = "",
  weight: int or string = "",
  uniform: bool or string = "",
  pad: int or string = "" 
) =
  w.tk.call(
    "grid rowconfigure",
    w,
    index,
    {
      "index": index,
      "minsize": minsize,
      "weight": weight,
      "uniform": uniform,
      "pad": pad
    }.toArgs()
  )

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
): string {.discardable.} =
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
): string {.discardable.} =
  getFileImpl("tk_getSaveFile")

# --- tk_messageBox

proc messageBox*(
  w: Widget,
  title: string = "",
  message: string = "",
  `type`: MessageBoxType = Ok,
  detail: string = "",
  default: ButtonName = Default,
  icon: IconImage = Info, 
  # parent: Widget = w,
): ButtonName {.discardable.} =
  parseEnum[ButtonName] w.tk.call(
    "tk_messageBox",
    {
      "default": $default,
      "detail": tclEscape detail,
      "icon": $icon,
      "message": tclEscape message,
      "parent": $w,
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

proc `bind`*(w: Widget, sequence: string = nil, command: TkEventCommand) =
  let name = genName("event_command_")

  w.tk.registerCmd(name, command)

  w.tk.call(
    "bind",
    w,
    tclEscape sequence,
    "{$1 %# %a %b %c %d %f %h %i %k %m %o %p %s %t %w %x %y %A %B %D %E %M %N %P %R %S %T %W %X %Y}" % name
  )

proc `bind`*(tk: Tk, className: string, sequence: string = nil, command: TkEventCommand) =
  let name = genName("event_command_" & className & "_")

  tk.registerCmd(name, command)

  tk.call(
    "bind",
    tclEscape className,
    tclEscape sequence,
    "{$1 %# %a %b %c %d %f %h %i %k %m %o %p %s %t %w %x %y %A %B %D %E %M %N %P %R %S %T %W %X %Y}" % name
  )

proc bindAll*(tk: Tk, sequence: string = nil, command: TkEventCommand) =
  let name = genName("event_command_ALL_")

  tk.registerCmd(name, command)

  tk.call(
    "bind",
    "all",
    tclEscape sequence,
    "{$1 %# %a %b %c %d %f %h %i %k %m %o %p %s %t %w %x %y %A %B %D %E %M %N %P %R %S %T %W %X %Y}" % name
  )

# --- bindtags

proc bindtags*(w: Widget, tagList: varargs[string, `$`]) = 
  w.tk.call("bindtags", w, tagList.toTclList())

proc bindtags*(w: Widget): seq[string] =
  w.tk.call("bindtags", w).split(' ')

# --- event

proc eventAdd*(tk: Tk, virtual: string, sequence: varargs[string]) =
  tk.call("event add", tclEscape virtual, sequence.join(" "))

proc eventDelete*(tk: Tk, virtual: string, sequence: varargs[string] = "") =
  tk.call("event delete", tclEscape virtual, sequence.join(" "))

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
      "above": tclEscape $eventObj.above,
      "borderwidth": tclEscape $eventObj.borderwidth,
      "button": tclEscape $eventObj.button,
      "count": tclEscape $eventObj.count,
      "data": tclEscape $eventObj.userData, # userdata
      "delta": tclEscape $eventObj.delta,
      "detail": tclEscape $eventObj.userData, # detail
      "focus": tclEscape $eventObj.focus,
      "height": tclEscape $eventObj.height,
      "keycode": tclEscape $eventObj.keycode,
      "keysym": tclEscape $eventObj.keysym,
      "mode": tclEscape $eventObj.mode,
      "override": tclEscape $eventObj.override,
      "place": tclEscape $eventObj.place,
      "root": tclEscape $eventObj.root,
      "rootx": tclEscape $eventObj.xRoot,
      "rooty": tclEscape $eventObj.yRoot,
      "sendevent": tclEscape $eventObj.sendevent,
      "serial": tclEscape $eventObj.serial,
      "state": tclEscape $eventObj.state,
      "subwindow": tclEscape $eventObj.subwindow,
      "time": tclEscape $eventObj.time,
      "warp": $warp,
      "width": tclEscape $eventObj.width,
      "when": tclEscape $eventObj.time,
      "x": tclEscape $eventObj.x
    }.toArgs()
  )

proc eventInfo*(tk: Tk): seq[string] =
  tk.call("event info").split(' ')

proc eventInfo*(tk: Tk, virtual: string): seq[string] =
  tk.call("event info", tclEscape virtual).split(' ')

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

proc selectionHandle*(w: Widget, selection = "PRIMARY", `type`: string = "UTF8_STRING", format: string = "STRING", command: TkSelectionHandleCommand) =
  var cmdname: string

  if command != nil:
    cmdname = genName("selection_handle_command_")
    w.tk.registerCmd(cmdname, command)
  else:
    cmdname = tclEscape ""
  
  w.tk.call("selection handle", {"selection": selection, "type": `type`}.toArgs, w, cmdname)

proc selectionOwn*(w: Widget, selection: string = "PRIMARY"): Widget =
  w.tk.call("selection own", {"selection": selection}.toArgs)

  if w.tk.result.len == 0:
    return nil

  return w.tk.newWidgetFromPathname(w.tk.result)

proc selectionOwn*(w: Widget, selection: string = "PRIMARY", command: TkGenericCommand) =
  var cmdname: string

  if command != nil:
    cmdname = genName("selection_own_command_")
    w.tk.registerCmd(cmdname, command)
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
proc `disabledforeground=`*(w: Widget, disabledforeground: Color or string)           = w.configure({"disabledforeground": tclEscape $disabledforeground})
proc `disabledbackground=`*(w: Widget, disabledbackground: Color or string)           = w.configure({"disabledbackground": tclEscape $disabledbackground})
proc `exportselection=`*(w: Widget, exportselection: bool)                            = w.configure({"exportselection": $exportselection})
#    proc `font=`*(w: Widget, font)                                                   = w.configure({"font": $font})
proc `foreground=`*(w: Widget, foreground: Color) {.alias: "fg=".}                    = w.configure({"foreground": $foreground})
# proc `height=`*(w: Widget, height: string or float or int)                            = w.configure({"height": $height})
proc `highlightbackground=`*(w: Widget, highlightbackground: Color)                   = w.configure({"highlightbackground": $highlightbackground})
proc `highlightcolor=`*(w: Widget, highlightcolor: Color)                             = w.configure({"highlightcolor": $highlightcolor})
proc `highlightthickness=`*(w: Widget, highlightthickness: string or float or int)    = w.configure({"highlightthickness": $highlightthickness})
# proc `image=`*(w: Widget, image)                                                    = w.configure({"image": $image}) # TODO
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
proc `xscrollcommand=`*(w: Widget, xscrollcommand: string)                            = w.configure({"xscrollcommand": tclEscape $xscrollcommand})
proc `yscrollcommand=`*(w: Widget, yscrollcommand: string)                            = w.configure({"yscrollcommand": tclEscape $yscrollcommand})

proc activebackground*(w: Widget): Color             = fromTclColor w, w.cget("activebackground")
proc activeborderwidth*(w: Widget): string           = w.cget("activeborderwidth")
proc activeforeground*(w: Widget): Color             = fromTclColor w, w.cget("activeforeground")
proc anchor*(w: Widget): AnchorPosition              = parseEnum[AnchorPosition] w.cget("anchor")
proc background*(w: Widget): Color {.alias: "bg".}   = fromTclColor w, w.cget("background")
proc borderwidth*(w: Widget): string {.alias: "bd".} = w.cget("borderwidth")
proc cursor*(w: Widget): Cursor                      = parseEnum[Cursor] w.cget("cursor")
proc compound*(w: Widget): WidgetCompound            = parseEnum[WidgetCompound] w.cget("compound")
proc disabledforeground*(w: Widget): Color           = fromTclColor w, w.cget("disabledforeground")
proc disabledbackground*(w: Widget): Color           = fromTclColor w, w.cget("disabledbackground")
proc exportselection*(w: Widget): bool               = w.cget("exportselection") == "1"
#    proc font*(w: Widget)                           = w.cget("font")
proc foreground*(w: Widget): Color {.alias: "fg".}   = fromTclColor w, w.cget("foreground")
# proc height*(w: Widget): string                      = w.cget("height")
proc highlightbackground*(w: Widget): Color          = fromTclColor w, w.cget("highlightbackground")
proc highlightcolor*(w: Widget): Color               = fromTclColor w, w.cget("highlightcolor")
proc highlightthickness*(w: Widget): string          = w.cget("highlightthickness")
#    proc image*(w: Widget)                          = w.cget("image")
proc insertbackground*(w: Widget): Color             = fromTclColor w, w.cget("insertbackground")
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
proc selectbackground*(w: Widget): Color             = fromTclColor w, w.cget("selectbackground")
proc selectborderwidth*(w: Widget): string           = w.cget("selectborderwidth")
proc selectforeground*(w: Widget): Color             = fromTclColor w, w.cget("selectforeground")
proc setgrid*(w: Widget): bool                       = w.cget("setgrid") == "1"
proc takefocus*(w: Widget): string                   = w.cget("takefocus")
proc text*(w: Widget): string                        = w.cget("text")
proc textvariable*(w: Widget): TkVar                 = createTkVar w.tk, w.cget("textvariable")
proc troughcolor*(w: Widget): Color                  = fromTclColor w, w.cget("troughcolor")
proc underline*(w: Widget): int                      = parseInt w.cget("underline")
# proc width*(w: Widget): string                       = w.cget("width")
proc wraplength*(w: Widget): int                     = parseInt w.cget("wraplength")
proc xscrollcommand*(w: Widget): string              = w.cget("xscrollcommand")
proc yscrollcommand*(w: Widget): string              = w.cget("yscrollcommand")

