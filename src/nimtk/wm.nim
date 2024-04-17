import std/strutils
import std/macros

import ./toplevel
import ./widget
import ./root
import ../nimtk

type
  Window* = Toplevel or Root

  WindowState* = enum
    Normal = "normal"
    Iconic = "iconic"
    Withdrawn = "withdrawn"
    Icon = "icon"

macro alias(name: string, fun: untyped) =
  result = newStmtList()

  result.add fun

  result.add newTree(
    nnkProcDef,      # we are defining a proc

    nnkPostfix.newTree(ident"*", ident(name.strVal)),  # proc name
    newEmptyNode(),  # term rewriting macros stuff
    fun[2],       # generic params
    fun[3],       # formal params
    fun[4],       # pragmas
    newEmptyNode(),  # reserved slot for future use by nim compiler
    fun[^1]       # MEAT
  )

# TODO multiple alias?

template lucky(op: string) {.dirty.} =
  let rest = initarr[1].split(op)

  result.height = rest[0].parseInt
  result.x = rest[1].parseInt
  result.y = rest[2].parseInt

  when op == "-":
    result.x = -result.x
    result.y = -result.y

template unlucky(op, op2: string) {.dirty.} =
  let
    piece1 {.gensym.} = initarr[1].split(op)
    piece2 {.gensym.} = piece1[1].split(op2)

  result.height = piece1[0].parseInt()
  result.x = piece2[0].parseInt()
  result.y = piece2[1].parseInt()

  when op == "-":
    result.x = -result.x
  else:
    result.y = -result.y

template stackorder() {.dirty.} =
  if w.tk.result.len == 0:
    return nil

  for pathname in w.tk.result.split(" "):
    result.add w.tk.newWidgetFromPathname(pathname)

proc wm_aspect*(w: Widget, minNumer, minDenom, maxNumer, maxDenom: int or string) {.alias: "aspect".} = w.tk.call("wm aspect", w, $minNumer, $minDenom, $maxNumer, $maxDenom)
proc wm_aspect*(w: Widget): array[4, int] {.alias: "aspect".} =
  w.tk.call("wm aspect", w)

  let res = w.tk.result.split(" ")

  for idx, num in res:
    result[idx] = num.parseInt()

proc wm_attributes*(w: Widget, option: string): string {.alias: "attributes".} =
  w.tk.call("wm attributes", w, '-' & option)
  w.tk.result
proc wm_attributes*(w: Widget, option, val: string) {.alias: "[]=".} = w.tk.call("wm attributes", w, '-' & option, val)
proc wm_attributes*(w: Widget, dict: openArray[(string, string)]) {.alias: "attributes".} = w.tk.call("wm attributes", w, dict.toArgs())
# proc wm_attributes window ?option value option value...?

#     -alpha 
#     -fullscreen 
#     -topmost 

#     -disabled 
#     -toolwindow 
#     -transparentcolor 

#     -modified 
#     -notify 
#     -titlepath 
#     -transparent 

#     -type
#         desktop 
#         dock 
#         toolbar 
#         menu 
#         utility 
#         splash 
#         dialog 
#         dropdown_menu 
#         popup_menu 
#         tooltip 
#         notification 
#         combo 
#         dnd 
#         normal 

#     -zoomed 

proc wm_client*(w: Widget, name: string) {.alias: "client=".} = w.tk.call("wm client", w, name)
proc wm_client*(w: Widget): string {.alias: "client".} =
  w.tk.call("wm client", w)
  w.tk.result

proc wm_colormapwindows*(w: Widget, windowList: seq[Widget]) {.alias: "colormapwindows=".} = w.tk.call("wm colormapwindows", w, windowList.join(" "))
proc wm_colormapwindows*(w: Widget): seq[Widget] {.alias: "colormapwindows".} =
  w.tk.call("wm colormapwindows", w)

  if w.tk.result == "0":
    return @[]

  for win in w.tk.result.split(" "):
    result.add w.tk.newWidgetFromPathname(win)

proc wm_command*(w: Widget, value: string) {.alias: "command=".} = w.tk.call("wm command", w, value)
proc wm_command*(w: Widget): string {.alias: "command".} =
  w.tk.call("wm command", w)
  w.tk.result

proc wm_deiconify*(w: Widget) {.alias: "deiconify".} = w.tk.call("wm deiconify", w)

proc wm_focusmodel*(w: Widget, focusmodel: FocusModel) {.alias: "focusmodel=".} = w.tk.call("wm focusmodel", w, focusmodel)
proc wm_focusmodel*(w: Widget): FocusModel {.alias: "focusmodel".} =
  w.tk.call("wm focusmodel", w)
  parseEnum[FocusModel] w.tk.result

proc wm_forget*(w: Widget) {.alias: "forget".} = w.tk.call("wm forget", w)

proc wm_frame*(w: Widget) {.alias: "frame".} = w.tk.call("wm frame", w)

proc wm_geometry*(w: Widget, newGeometry: string) {.alias: "geometry=".} = w.tk.call("wm geometry", w, newGeometry)
proc wm_geometry*(w: Widget, width, height: int) {.alias: "geometry".} = w.tk.call("wm geometry", w, $width & 'x' & $height)
proc wm_geometry*(w: Widget, x, y: int) {.alias: "geometry".} =
  let
    xstr = if x >= 0: '+' & $x else: $x
    ystr = if y >= 0: '+' & $y else: $y

  w.tk.call("wm geometry", w, xstr & ystr)
proc wm_geometry*(w: Widget): tuple[width, height, x, y: int] {.alias: "geometry".} =
  w.tk.call("wm geometry", w)
  
  let initarr = w.tk.result.split("x")

  result.width = initarr[0].parseInt()

  if '+' in initarr[1] and '-' notin initarr[1]:
    lucky("+")
  elif '-' in initarr[1] and '+' notin initarr[1]:
    lucky("-")
  else:
    # ???-???+???
    if initarr[1].find('+') > initarr[1].find('-'):
      unlucky("-", "+")
    else:
      unlucky("+", "-")

proc wm_grid*(w: Widget, baseWidth, baseHeight, widthInc, heightInc: int) {.alias: "grid".} = 
  w.tk.call("wm grid", w, $baseWidth, $baseHeight, $widthInc, $heightInc)
proc wm_grid*(w: Widget): array[4, int] {.alias: "grid".} = # TODO why is this an array
  w.tk.call("wm grid", w)

  let res = w.tk.result.split(" ")

  for idx, num in res:
    result[idx] = num.parseInt()

proc wm_group*(w: Widget, leader: Widget or string) {.alias: "group=".} = w.tk.call("wm group", w, leader)
proc wm_group*(w: Widget): Widget {.alias: "group".} =
  w.tk.call("wm group", w)

  if w.tk.result.len == 0: return nil
  else: return w.tk.newWidgetFromPathname(w.tk.result)

proc wm_iconbitmap*(w: Widget, bitmap: string, default: bool = false) {.alias: "iconbitmap=".} =
  if default:
    w.tk.call("wm iconbitmap", w, "-default", bitmap)
  else:
    w.tk.call("wm iconbitmap", w, '$' & $bitmap)

  w.tk.call("wm iconbitmap", w)
  echo w.tk.result
# proc wm_iconify*(w: Widget) = discard
# proc wm_iconmask*(w: Widget ?bitmap?) = discard
# proc wm_iconname*(w: Widget ?newName?) = discard
# proc wm_iconphoto*(w: Widget ?-default? image1 ?image2 ...?) = discard
# proc wm_iconposition*(w: Widget ?x y?) = discard
# proc wm_iconwindow*(w: Widget ?pathName?) = discard
# proc wm_manage*(w: Widget) = discard
# proc wm_maxsize*(w: Widget ?width height?) = discard
# proc wm_minsize*(w: Widget ?width height?) = discard
# proc wm_overrideredirect*(w: Widget ?boolean?) = discard
# proc wm_positionfrom*(w: Widget ?who?) = discard
# proc wm_protocol*(w: Widget ?name? ?command?) = discard

proc wm_resizable*(w: Widget, width, height: bool) {.alias: "resizable".} = w.tk.call("wm resizable", w, width, height)
proc wm_resizable*(w: Widget, both: bool) {.alias: "resizable=".} = w.tk.call("wm resizable", w, both, both)
proc wm_resizable*(w: Widget): tuple[width, height: bool] {.alias: "resizable".} =
  w.tk.call("wm resizable", w)

  let res = w.tk.result.split(" ")

  result.width = res[0] == "1"
  result.height = res[1] == "1"

proc wm_sizefrom*(w: Widget, who: string) {.alias: "sizefrom".} = w.tk.call("wm sizefrom", w, who)
proc wm_sizefrom*(w: Widget): string {.alias: "sizefrom".} =
  w.tk.call("wm sizefrom", w)
  w.tk.result

proc wm_stackorder*(w: Widget, isbelow: Window): seq[Widget] {.alias: "stackorder".} =
  w.tk.call("wm stackorder", w, "isbelow", isbelow)
  stackorder()
proc wm_stackorder*(w: Widget, isabove: Window): seq[Widget] {.alias: "stackorder".} =
  w.tk.call("wm stackorder", w, "isabove", isabove)
  stackorder()

proc wm_state*(w: Widget, newstate: WindowState) {.alias: "state=".} = w.tk.call("wm state", w, newstate)
proc wm_state*(w: Widget): WindowState {.alias: "state".} =
  w.tk.call("wm state", w)
  parseEnum[WindowState] w.tk.result

proc wm_title*(w: Widget, title: string) {.alias: "title=".} = w.tk.call("wm title", w, title)
proc wm_title*(w: Widget): string {.alias: "title".} =
  w.tk.call("wm title", w)
  w.tk.result

proc wm_transient*(w: Widget, container: Widget) {.alias: "transient=".} = w.tk.call("wm transient", w, container)
proc wm_transient*(w: Widget): Widget {.alias: "transient".} =
  w.tk.call("wm transient", w)

  if w.tk.result.len == 0: return nil
  else: return w.tk.newWidgetFromPathname(w.tk.result)

proc wm_withdraw*(w: Widget) {.alias: "withdraw".} = w.tk.call("wm withdraw", w)

# ---

