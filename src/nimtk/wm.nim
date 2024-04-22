import std/strutils
import std/macros

import std/colors

import ./private/escaping
import ./private/alias
import ./widgets
import ../nimtk

type
  Window* = Toplevel or Root

# used in winfo
template lucky*(op: string) {.dirty.} =
  let rest = res[1].split(op)

  result.height = rest[0].parseInt
  result.x = rest[1].parseInt
  result.y = rest[2].parseInt

  when op == "-":
    result.x = -result.x
    result.y = -result.y

template unlucky(op, op2: string) {.dirty.} =
  let
    piece1 = res[1].split(op)
    piece2 = piece1[1].split(op2)

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

proc wm_aspect*(w: Window, minNumer, minDenom, maxNumer, maxDenom: int or string) {.alias: "aspect".} = w.tk.call("wm aspect", w, $minNumer, $minDenom, $maxNumer, $maxDenom)
proc wm_aspect*(w: Window): array[4, int] {.alias: "aspect".} =
  w.tk.call("wm aspect", w)

  let res = w.tk.result.split(" ")

  for idx, num in res:
    result[idx] = num.parseInt()

proc wm_attributes*(w: Window, option: string): string {.alias: "attributes".} = w.tk.call("wm attributes", w, '-' & option)
proc wm_attributes*(w: Window, option, val: string) {.alias: "[]=".} = w.tk.call("wm attributes", w, '-' & option, val)
proc wm_attributes*(w: Window, dict: openArray[(string, string)]) {.alias: "attributes".} = w.tk.call("wm attributes", w, dict.toArgs())

#! these

# -- getters

proc alpha*(w: Window): float = parseFloat w.wm_attributes("alpha")
proc fullscreen*(w: Window): bool = parseBool w.wm_attributes("fullscreen")
proc topmost*(w: Window): bool = parseBool w.wm_attributes("topmost")

when defined(windows):
  proc disabled*(w: Window): bool = parseBool w.wm_attributes("disabled")
  proc toolwindow*(w: Window): bool = parseBool w.wm_attributes("toolwindow")
  proc transparentcolor*(w: Window): Color = parseColor w.wm_attributes("transparentcolor")

elif defined(macos):
  proc modified*(w: Window): bool = parseBool w.wm_attributes("modified")
  proc notify*(w: Window): string = w.wm_attributes("notify")
  proc titlepath*(w: Window): string = w.wm_attributes("titlepath")
  proc transparent*(w: Window): bool = parseBool w.wm_attributes("transparent")

else:
  proc type*(w: Window): WindowType = parseEnum[WindowType] w.wm_attributes("type")

proc zoomed*(w: Window): bool = parseBool w.wm_attributes("zoomed")

# -- setters

proc `alpha=`*(w: Window, alpha: float) = w.wm_attributes("alpha", $alpha)
proc `fullscreen=`*(w: Window, fullscreen: bool) = w.wm_attributes("fullscreen", $fullscreen)
proc `topmost=`*(w: Window, topmost: bool) = w.wm_attributes("topmost", $topmost)

when defined(macos):
  proc `disabled=`*(w: Window, disabled: bool) = w.wm_attributes("disabled", $disabled)
  proc `toolwindow=`*(w: Window, toolwindow: bool) = w.wm_attributes("toolwindow", $toolwindow)
  proc `transparentcolor=`*(w: Window, transparentcolor: Color) = w.wm_attributes("transparentcolor", $transparentcolor)

elif defined(macos):
  proc `modified=`*(w: Window, modified: bool) = w.wm_attributes("modified", $modified)
  proc `notify=`*(w: Window, notify: string) = w.wm_attributes("notify", $notify)
  proc `titlepath=`*(w: Window, titlepath: string) = w.wm_attributes("titlepath", $titlepath)
  proc `transparent=`*(w: Window, transparent: bool) = w.wm_attributes("transparent", $transparent)

else:
  proc `type=`*(w: Window, `type`: WindowType) = w.wm_attributes("type", $`type`)

proc `zoomed=`*(w: Window, zoomed: bool) = w.wm_attributes("zoomed", $zoomed)

# -- others...

proc wm_client*(w: Window, name: string) {.alias: "client=".} = w.tk.call("wm client", w, name)
proc wm_client*(w: Window): string {.alias: "client".} =
  w.tk.call("wm client", w)

proc wm_colormapwindows*(w: Window, windowList: seq[Widget]) {.alias: "colormapwindows=".} = w.tk.call("wm colormapwindows", w, windowList.join(" "))
proc wm_colormapwindows*(w: Window): seq[Widget] {.alias: "colormapwindows".} =
  w.tk.call("wm colormapwindows", w)

  if w.tk.result == "0":
    return @[]

  for win in w.tk.result.split(" "):
    result.add w.tk.newWidgetFromPathname(win)

proc wm_command*(w: Window, value: string) {.alias: "command=".} = w.tk.call("wm command", w, value)
proc wm_command*(w: Window): string {.alias: "command".} =
  w.tk.call("wm command", w)

proc wm_deiconify*(w: Window) {.alias: "deiconify".} = w.tk.call("wm deiconify", w)

proc wm_focusmodel*(w: Window, focusmodel: FocusModel) {.alias: "focusmodel=".} = w.tk.call("wm focusmodel", w, focusmodel)
proc wm_focusmodel*(w: Window): FocusModel {.alias: "focusmodel".} =
  parseEnum[FocusModel] w.tk.call("wm focusmodel", w)

proc wm_forget*(w: Window) {.alias: "forget".} = w.tk.call("wm forget", w)

proc wm_frame*(w: Window) {.alias: "frame".} = w.tk.call("wm frame", w)

proc wm_geometry*(w: Window, newGeometry: string) {.alias: "geometry=".} = w.tk.call("wm geometry", w, newGeometry)
proc wm_geometry*(w: Window, width, height: int) {.alias: "geometry".} = w.tk.call("wm geometry", w, $width & 'x' & $height)
proc wm_geometry*(w: Window, x, y: int) {.alias: "geometry".} =
  let
    xstr = if x >= 0: '+' & $x else: $x
    ystr = if y >= 0: '+' & $y else: $y

  w.tk.call("wm geometry", w, xstr & ystr)
proc wm_geometry*(w: Window): tuple[width, height, x, y: int] = # {.alias: "geometry".}
  w.tk.call("wm geometry", w)
  
  let res = w.tk.result.split("x")

  result.width = res[0].parseInt()

  if '+' in res[1] and '-' notin res[1]:
    lucky("+")
  elif '-' in res[1] and '+' notin res[1]:
    lucky("-")
  else:
    # ???-???+???
    if res[1].find('+') > res[1].find('-'):
      unlucky("-", "+")
    else:
      unlucky("+", "-")

proc wm_grid*(w: Window, baseWidth, baseHeight, widthInc, heightInc: int) {.alias: "grid".} = 
  w.tk.call("wm grid", w, $baseWidth, $baseHeight, $widthInc, $heightInc)
proc wm_grid*(w: Window): array[4, int] {.alias: "grid".} = # TODO why is this an array
  w.tk.call("wm grid", w)

  let res = w.tk.result.split(" ")

  for idx, num in res:
    result[idx] = num.parseInt()

proc wm_group*(w: Window, leader: Widget or string) {.alias: "group=".} = w.tk.call("wm group", w, leader)
proc wm_group*(w: Window): Widget {.alias: "group".} =
  w.tk.call("wm group", w)

  if w.tk.result.len == 0: return nil
  else: return w.tk.newWidgetFromPathname(w.tk.result)

proc wm_iconbitmap*(w: Window, bitmap: string, default: bool = false) {.alias: "iconbitmap=".} =
  if default:
    w.tk.call("wm iconbitmap", w, "-default", bitmap)
  else:
    w.tk.call("wm iconbitmap", w, bitmap)

proc wm_iconify*(w: Window) {.alias: "iconify".} = w.tk.call("wm iconify", w)

proc wm_iconmask*(w: Window, bitmap: string) {.alias: "iconmask=".} = w.tk.call("wm iconmask", w, bitmap)
proc wm_iconmask*(w: Window): string {.alias: "iconmask".} =
  w.tk.call("wm iconmask", w)

proc wm_iconname*(w: Window, newName: string) {.alias: "iconname=".} = w.tk.call("wm iconname", w, newName)
proc wm_iconname*(w: Window): string {.alias: "iconname".} =
  w.tk.call("wm iconname", w)

proc wm_iconphoto*(w: Window, images: string) {.alias: "iconphoto=".} = w.tk.call("wm iconphoto", w, images)
proc wm_iconphoto*(w: Window, images: varargs[string]) {.alias: "iconphoto".} = w.tk.call("wm iconphoto", w, images.join(" "))
proc wm_iconphoto*(w: Window, default: bool, images: varargs[string]) {.alias: "iconphoto".} = w.tk.call("wm iconphoto", w, "-default", images.join(" "))

proc wm_iconposition*(w: Window, x, y: int or string) {.alias: "iconposition".} = w.tk.call("wm iconposition", $x, $y)
proc wm_iconposition*(w: Window): tuple[x, y: int, nohints: bool] {.alias: "iconposition".} =
  w.tk.call("wm iconposition")

  if w.tk.result.len == 0:
    result.nohints = true
  else:
    let xy = w.tk.result.split(" ")

    result.x = xy[0].parseInt()
    result.y = xy[1].parseInt()

proc wm_iconwindow*(w: Window, window: Window) {.alias: "iconwindow=".} = w.tk.call("wm iconwindow", window)
proc wm_iconwindow*(w: Window): Widget {.alias: "iconwindow".} =
  w.tk.call("wm iconwindow")

  if w.tk.result.len == 0: return nil
  else: return w.tk.newWidgetFromPathname(w.tk.result)

proc wm_manage*(w: Frame or LabelFrame or Toplevel) {.alias: "manage".} = w.tk.call("wm manage", w)

proc wm_maxsize*(w: Window, size: tuple[width, height: int]) {.alias: "maxsize=".} = w.tk.call("wm maxsize", w, $size.width, $size.height)
proc wm_maxsize*(w: Window, width, height: int) {.alias: "maxsize".} = w.tk.call("wm maxsize", w, $width, $height)
proc wm_maxsize*(w: Window): tuple[width, height: int] {.alias: "maxsize".} =
  w.tk.call("wm maxsize")

  let wh = w.tk.result.split(" ")

  result.width = wh[0].parseInt()
  result.height = wh[1].parseInt()

proc wm_minsize*(w: Window, size: tuple[width, height: int]) {.alias: "minsize=".} = w.tk.call("wm minsize", w, $size.width, $size.height)
proc wm_minsize*(w: Window, width, height: int) {.alias: "minsize=".} = w.tk.call("wm minsize", w, $width, $height)
proc wm_minsize*(w: Window): tuple[width, height: int] {.alias: "minsize=".} =
  w.tk.call("wm minsize")

  let wh = w.tk.result.split(" ")

  result.width = wh[0].parseInt()
  result.height = wh[1].parseInt()

proc wm_overrideredirect*(w: Window, overrideredirect: bool) {.alias: "overrideredirect=".} = w.tk.call("wm overridedirect", w, overrideredirect)
proc wm_overrideredirect*(w: Window): bool {.alias: "overrideredirect".} =
  w.tk.call("wm overridedirect", w) == "1"

proc wm_positionfrom*(w: Window, who: PositionFrom) {.alias: "positionfrom=".} = w.tk.call("wm positionfrom", w, who)
proc wm_positionfrom*(w: Window): PositionFrom {.alias: "positionfrom".} =
  parseEnum[PositionFrom] w.tk.call("wm positionfrom", w)

proc wm_protocol*(w: Window, name: string, clientdata: pointer, command: TkWidgetCommand) {.alias: "protocol".} =
  let cmdname = genName("wm_protocol_command_")
  
  w.tk.registerCmd(w, clientdata, cmdname, command)

  w.tk.call("wm protocol", w, tclEscape name, cmdname)

proc wm_resizable*(w: Window, width, height: bool) {.alias: "resizable".} = w.tk.call("wm resizable", w, width, height)
proc wm_resizable*(w: Window, both: bool) {.alias: "resizable=".} = w.tk.call("wm resizable", w, both, both)
proc wm_resizable*(w: Window): tuple[width, height: bool] {.alias: "resizable".} =
  w.tk.call("wm resizable", w)

  let res = w.tk.result.split(" ")

  result.width = res[0] == "1"
  result.height = res[1] == "1"

proc wm_sizefrom*(w: Window, who: PositionFrom) {.alias: "sizefrom".} = w.tk.call("wm sizefrom", w, $who)
proc wm_sizefrom*(w: Window): PositionFrom {.alias: "sizefrom".} =
  parseEnum[PositionFrom] w.tk.call("wm sizefrom", $w)

proc wm_stackorder*(w: Window, isbelow: Window): seq[Widget] {.alias: "stackorder".} =
  w.tk.call("wm stackorder", w, "isbelow", isbelow)
  stackorder()
proc wm_stackorder*(w: Window, isabove: Window): seq[Widget] {.alias: "stackorder".} =
  w.tk.call("wm stackorder", w, "isabove", isabove)
  stackorder()

proc wm_state*(w: Window, newstate: WindowState) {.alias: "state=".} = w.tk.call("wm state", w, newstate)
proc wm_state*(w: Window): WindowState {.alias: "state".} =
  parseEnum[WindowState] w.tk.call("wm state", w)

proc wm_title*(w: Window, title: string) {.alias: "title=".} = w.tk.call("wm title", w, title)
proc wm_title*(w: Window): string {.alias: "title".} =
  w.tk.call("wm title", w)

proc wm_transient*(w: Window, container: Widget) {.alias: "transient=".} = w.tk.call("wm transient", w, container)
proc wm_transient*(w: Window): Widget {.alias: "transient".} =
  w.tk.call("wm transient", w)

  if w.tk.result.len == 0: return nil
  else: return w.tk.newWidgetFromPathname(w.tk.result)

proc wm_withdraw*(w: Window) {.alias: "withdraw".} = w.tk.call("wm withdraw", w)

# ---

