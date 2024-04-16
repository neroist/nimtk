import std/strutils
import std/tables
import std/colors

import nimtcl

import ./variables
import ../nimtk

export variables

type
  Widget* = ref object of RootObj
    pathname*: string
    tk*: Tk
  
  TkCommand* = proc (clientdata: pointer, widget: Widget)
  TkSelectionOwnCmd* = proc (clientdata: pointer, offset, maxChars: int)
  TkSelectionHandle* = proc (clientdata: pointer)

  TkCmdData* = ref object
    clientdata*: pointer
    widget*: Widget
    fun*: TkCommand

  TkSelectionOwnCmdData* = ref object
    clientdata*: pointer
    fun*: TkSelectionOwnCmd

  TkSelectionHandleData* = ref object
    clientdata*: pointer
    fun*: TkSelectionHandle

proc tkintcmd*(clientData: ClientData, _: ptr Interp, _: cint, argv: cstringArray): cint {.cdecl.} =
  var data = cast[TkCmdData](clientData)

  if data != nil:
    data.fun(data.clientdata, data.widget)

  return TCL_OK

proc tkintselowncmd*(clientData: ClientData, interp: ptr Interp, argc: cint, argv: cstringArray): cint {.cdecl.} =
  let data = cast[TkSelectionOwnCmdData](clientData)
  let args = argv.cstringArrayToSeq()

  data.fun(data.clientdata, args[0].parseInt(), args[1].parseInt())

  return TCL_OK

proc tkintselhandle*(clientData: ClientData, interp: ptr Interp, argc: cint, argv: cstringArray): cint {.cdecl.} =
  let data = cast[TkSelectionHandleData](clientData)

  data.fun(data.clientdata)

  return TCL_OK

template registerCmd*(tk: Tk, w: Widget, clientdata1: pointer, name: string, cmd: TkCommand) =
  let data {.gensym.} = new TkCmdData
  data.clientdata = clientdata1
  data.widget = w
  data.fun = cmd

  discard tk.interp.createCommand(
    cstring name,
    tkintcmd,
    clientdata = cast[pointer](data)
  )

proc `$`*(w: Widget): string = 
  if w != nil: w.pathname
  else: ""

proc newWidgetFromPathname*(tk: Tk, pathname: string): Widget =
  new result

  result.tk = tk
  result.pathname = pathname

proc pathName*(names: varargs[string]): string {.inline.} =
  result = names.join(".")

  if names[0] == ".":
    result = result[1..^1] # discard leading extra '.'

template configure*(w: Widget or typed, args: openArray[(string, string)]) =
  discard w.tk.call($w, "configure", args.toArgs())

template cget*(w: Widget or typed, option: string): string =
  w.tk.call($w, "cget", {option: " "}.toArgs())
  w.tk.result

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

proc pack*(
  w: Widget,
  after: Widget = nil,
  anchor: AnchorPosition = Center,
  before: Widget = nil,
  expand: bool = false,
  fill: FillStyle = None,
  `in`: Widget = nil,
  ipadx: float = 0,
  ipady: float = 0,
  padx: float = 0,
  pady: float = 0,
  side: Side = Top
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
      "padx": $padx,
      "pady": $pady,
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
  height: string,
  `in`: Widget = nil,
  relheight: float = 1,
  relwidth: float = 1,
  relx: float = 0,
  rely: float = 0,
  width: string,
  x: string,
  y: string
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

proc grid*(
  w: Widget,
  column: string = "",
  columnspan: string = "",
  `in`: Widget = nil,
  ipadx: float = 0,
  ipady: float = 0,
  padx: (float, float) = (0, 0),
  pady: (float, float) = (0, 0),
  row: string = "",
  rowspan: string = "",
  sticky: FillStyle or AnchorPosition or string = ""
) =
  w.tk.call(
    "grid configure",
    w,
    {
      "column": column,
      "columnspan": columnspan,
      "in": $`in`,
      "ipadx": $ipadx,
      "ipady": $ipady,
      "padx": "{$1 $2}" % [$padx[0], $padx[1]],
      "pady": "{$1 $2}" % [$pady[0], $pady[1]],
      "row": row,
      "rowspan": rowspan,
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
  w.tk.call("grid propagate", w)

  w.tk.result == "1"

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

proc busyConfigure*(w: Widget, cursorName: string) =
  w.tk.call("tk busy configure", w, {"cursor": cursorName}.toArgs())

proc busyConfigure*(w: Widget): seq[string] =
  w.tk.call("tk busy configure", w)
  w.tk.result[1..^2].split()[3..^1]

proc busyForget*(w: Widget) =
  w.tk.call("tk busy forget", w)

proc busyCurrent*(w: Widget, pattern: string = ""): seq[Widget] =
  w.tk.call("tk busy current", w, {"pattern": pattern}.toArgs)

  w.slavesImpl()

proc busyStatus*(w: Widget): bool =
  w.tk.call("tk busy status", w)
  
  w.tk.result == "1"

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
      "initialdir": repr initialdir,
      "mustexist": $mustexist,
      "title": repr title,
    }.toArgs()
  )

  w.tk.result

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
      "title": repr title,
    }.toArgs()
  )

  w.tk.result.parseColor()

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
      "filetypes": '{' & filetypesList.join(" ") & '}',
      "initialdir": repr initialdir,
      "initialfile": repr initialfile,
      "multiple": $multiple,
      "parent": $parent,
      "title": repr title,
      "typevariable": $typevariable
    }.toArgs()
  )

  w.tk.result

proc getOpenFile*(
  w: Widget,
  defaultextension: string = "",
  filetypes: openArray[tuple[typeName: string, extentions, macTypes: seq[string]]] = @[], # seq because openArray is an "invalid type"
  initialdir: string = "",
  initialfile: string = "",
  multiple: bool = false,
  parent: Widget = w,
  title: string = "",
  typevariable: TkString = nil
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
  typevariable: TkString = nil
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
) =
  w.tk.call(
    "tk_messageBox",
    {
      "default": $default,
      "detail": repr detail,
      "icon": $icon,
      "message": repr message,
      "parent": $parent,
      "title": repr title,
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
    opts.add repr $option[1]

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
  
  w.tk.result

proc grabCurrent*(w: Widget): Widget =
  w.tk.call("grab current", w)
  
  if w.tk.result.len == 0:
    return nil

  return w.tk.newWidgetFromPathname(w.tk.result)

proc grabCurrent*(tk: Tk): seq[Widget] =
  tk.call("grab current")
  
  if tk.result.len == 0:
    return @[nil]

  for pathname in tk.result.split():
    result.add tk.newWidgetFromPathname(pathname)

# --- bell

proc bell*(w: Widget, nice: bool = false) =
  let argNice = if nice == false: "" else: " "

  w.tk.call("bell", {"displayof": $w, "nice": $argNice}.toArgs)

# proc bell*(tk: Tk, nice: bool = false) =
#   let argNice = if nice == false: "" else: " "
# 
#   tk.call("bell", {"nice": $argNice}.toArgs)

# --- clipboard

proc clipboardAdd*(w: Widget, data: string; format = "STRING", `type`: string = "STRING") =
  w.tk.call(
    "clipboard append",
    {"displayof": $w, "format": format, "type": `type`}.toArgs,
    "--",
    repr data
  )

proc clipboardClear*(w: Widget) =
  w.tk.call("clipboard clear", {"displayof": $w}.toArgs)

proc clipboardGet*(w: Widget, `type`: string = "UTF8_STRING"): string =
  w.tk.call("clipboard get", {"displayof": $w, "type": `type`}.toArgs)

  w.tk.result

# --- selection

proc selectionClear*(w: Widget, selection: string = "PRIMARY") =
  w.tk.call("selection clear", {"displayof": $w, "selection": selection}.toArgs)

proc selectionGet*(w: Widget, selection = "PRIMARY", `type`: string = "UTF8_STRING"): string =
  w.tk.call("selection get", {"displayof": $w, "selection": selection, "type": `type`}.toArgs)
  w.tk.result

#! selection handle
#! selection own

# --- tkwait

proc wait*(tkvar: TkVar) =
  tkvar.tk.call("tkwait variable", tkvar.varname)

proc waitVisibility*(w: Widget) =
  w.tk.call("tkwait visiblity", w)

proc waitWindow*(w: Widget) =
  w.tk.call("tkwait window", w)

# --- --- Common widget options

proc `activebackground=`*(w: Widget, activebackground: Color) = w.configure({"activebackground": $activebackground})
proc `activeborderwidth=`*(w: Widget, activeborderwidth: string or float or int) = w.configure({"activeborderwidth": $activeborderwidth})
proc `activeforeground=`*(w: Widget, activeforeground: Color) = w.configure({"activeforeground": $activeforeground})
proc `anchor=`*(w: Widget, anchor: AnchorPosition) = w.configure({"anchor": $anchor})
proc `background=`*(w: Widget, background: Color) = w.configure({"background": $background})
proc `borderwidth=`*(w: Widget, borderwidth: string or float or int) = w.configure({"borderwidth": $borderwidth})
proc `cursor=`*(w: Widget, cursor: Cursor) = w.configure({"cursor": $cursor})
proc `compound=`*(w: Widget, compound: WidgetCompound) = w.configure({"compound": $compound})
proc `disabledforeground=`*(w: Widget, disabledforeground: Color) = w.configure({"disabledforeground": $disabledforeground})
proc `exportselection=`*(w: Widget, exportselection: bool) = w.configure({"exportselection": $exportselection})
# proc `font=`*(w: Widget, font) = w.configure({"font": $font})
proc `foreground=`*(w: Widget, foreground: Color) = w.configure({"foreground": $foreground})
proc `highlightbackground=`*(w: Widget, highlightbackground: Color) = w.configure({"highlightbackground": $highlightbackground})
proc `highlightcolor=`*(w: Widget, highlightcolor: Color) = w.configure({"highlightcolor": $highlightcolor})
proc `highlightthickness=`*(w: Widget, highlightthickness: string or float or int) = w.configure({"highlightthickness": $highlightthickness})
# proc `image=`*(w: Widget, image) = w.configure({"image": $image})
proc `insertbackground=`*(w: Widget, insertbackground: Color) = w.configure({"insertbackground": $insertbackground})
proc `insertborderwidth=`*(w: Widget, insertborderwidth: string or float or int) = w.configure({"insertborderwidth": $insertborderwidth})
proc `insertofftime=`*(w: Widget, insertofftime: int) = w.configure({"insertofftime": $insertofftime})
proc `insertontime=`*(w: Widget, insertontime: int) = w.configure({"insertontime": $insertontime})
proc `insertwidth=`*(w: Widget, insertwidth: string) = w.configure({"insertwidth": $insertwidth})
proc `jump=`*(w: Widget, jump: bool) = w.configure({"jump": $jump})
proc `justify=`*(w: Widget, justify: TextJustify) = w.configure({"justify": $justify})
proc `orient=`*(w: Widget, orient: WidgetOrientation) = w.configure({"orient": $orient})
proc `padx=`*(w: Widget, padx: string or float or int) = w.configure({"padx": $padx})
proc `pady=`*(w: Widget, pady: string or float or int) = w.configure({"pady": $pady})
proc `relief=`*(w: Widget, relief: WidgetRelief) = w.configure({"relief": $relief})
proc `repeatdelay=`*(w: Widget, repeatdelay: float) = w.configure({"repeatdelay": $repeatdelay})
proc `repeatinterval=`*(w: Widget, repeatinterval: float) = w.configure({"repeatinterval": $repeatinterval})
proc `selectbackground=`*(w: Widget, selectbackground: Color) = w.configure({"selectbackground": $selectbackground})
proc `selectborderwidth=`*(w: Widget, selectborderwidth: string or float or int) = w.configure({"selectborderwidth": $selectborderwidth})
proc `selectforeground=`*(w: Widget, selectforeground: Color) = w.configure({"selectforeground": $selectforeground})
proc `setgrid=`*(w: Widget, setgrid: bool) = w.configure({"setgrid": $setgrid})
proc `takefocus=`*(w: Widget, takefocus: bool or string) = w.configure({"takefocus": $takefocus})
proc `text=`*(w: Widget, text: string) = w.configure({"text": repr text})
proc `textvariable=`*(w: Widget, textvariable: TkVar) = w.configure({"textvariable": $textvariable})
proc `troughcolor=`*(w: Widget, troughcolor: Color) = w.configure({"troughcolor": $troughcolor})
proc `underline=`*(w: Widget, underline: int) = w.configure({"underline": $underline})
proc `wraplength=`*(w: Widget, wraplength: int) = w.configure({"wraplength": $wraplength})

proc activebackground*(w: Widget): Color = parseColor w.cget("activebackground")
proc activeborderwidth*(w: Widget): string = w.cget("activeborderwidth")
proc activeforeground*(w: Widget): Color = parseColor w.cget("activeforeground")
proc anchor*(w: Widget): AnchorPosition = parseEnum[AnchorPosition] w.cget("anchor")
proc background*(w: Widget): Color = parseColor w.cget("background")
proc borderwidth*(w: Widget): string = w.cget("borderwidth")
proc cursor*(w: Widget): Cursor = parseEnum[Cursor] w.cget("cursor")
proc compound*(w: Widget): WidgetCompound = parseEnum[WidgetCompound] w.cget("compound")
proc disabledforeground*(w: Widget): Color = parseColor w.cget("disabledforeground")
proc exportselection*(w: Widget): bool = w.cget("exportselection") == "1"
# proc font*(w: Widget) = w.cget("font")
proc foreground*(w: Widget): Color = parseColor w.cget("foreground")
proc highlightbackground*(w: Widget): Color = parseColor w.cget("highlightbackground")
proc highlightcolor*(w: Widget): Color = parseColor w.cget("highlightcolor")
proc highlightthickness*(w: Widget): string = w.cget("highlightthickness")
# proc image*(w: Widget) = w.cget("image")
proc insertbackground*(w: Widget): Color = parseColor w.cget("insertbackground")
proc insertborderwidth*(w: Widget): string = w.cget("insertborderwidth")
proc insertofftime*(w: Widget): int = parseInt w.cget("insertofftime")
proc insertontime*(w: Widget): int = parseInt w.cget("insertontime")
proc insertwidth*(w: Widget): string = w.cget("insertwidth")
proc jump*(w: Widget): bool = w.cget("jump") == "1"
proc justify*(w: Widget): TextJustify = parseEnum[TextJustify] w.cget("justify")
proc orient*(w: Widget): WidgetOrientation = parseEnum[WidgetOrientation] w.cget("orient")
proc padx*(w: Widget): string = w.cget("padx")
proc pady*(w: Widget): string = w.cget("pady")
proc relief*(w: Widget): WidgetRelief = parseEnum[WidgetRelief] w.cget("relief")
proc repeatdelay*(w: Widget): float = parseFloat w.cget("repeatdelay")
proc repeatinterval*(w: Widget): float = parseFloat w.cget("repeatinterval")
proc selectbackground*(w: Widget): Color = parseColor w.cget("selectbackground")
proc selectborderwidth*(w: Widget): string = w.cget("selectborderwidth")
proc selectforeground*(w: Widget): Color = parseColor w.cget("selectforeground")
proc setgrid*(w: Widget): bool = w.cget("setgrid") == "1"
proc takefocus*(w: Widget): string = w.cget("takefocus")
proc text*(w: Widget): string = w.cget("text")
proc textvariable*(w: Widget): TkString =
  new result

  result.varname = w.cget("textvariable")
  result.tk = w.tk
proc troughcolor*(w: Widget): Color = parseColor w.cget("troughcolor")
proc underline*(w: Widget): int = parseInt w.cget("underline")
proc wraplength*(w: Widget): int = parseInt w.cget("wraplength")
