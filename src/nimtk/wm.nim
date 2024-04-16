import std/strutils

import ./toplevel
import ./widget
import ./root
import ../nimtk

type
  Window* = Toplevel or Root

proc wm_aspect*(w: Widget, minNumer, minDenom, maxNumer, maxDenom: int) = w.tk.call("wm aspect", w, $minNumer, $minDenom, $maxNumer, $maxDenom)
proc wm_aspect*(w: Widget): array[4, int] =
  w.tk.call("wm aspect", w)

  let res = w.tk.result.split(" ")

  for idx, num in res:
    result[idx] = num.parseInt()
proc wm_attributes*(w: Widget, option: string): string =
  w.tk.call("wm attributes", w, '-' & option)
  w.tk.result
proc wm_attributes*(w: Widget, option, val: string) = w.tk.call("wm attributes", w, '-' & option, val)
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

proc wm_client*(w: Widget, name: string) = w.tk.call("wm client", w, name)
proc wm_colormapwindows*(w: Widget, windowList: seq[Widget]) = w.tk.call("wm colormapwindows", w, windowList.join(" "))
proc wm_colormapwindows*(w: Widget): seq[Widget] =
  w.tk.call("wm colormapwindows", w)

  for win in w.tk.result.split(" "):
    result.add w.tk.newWidgetFromPathname(win)
proc wm_command*(w: Widget, value: string) = w.tk.call("wm command", w, value)
proc wm_deiconify*(w: Widget) = w.tk.call("wm deiconify", w)
proc wm_focusmodel*(w: Widget, focusmodel: FocusModel) = w.tk.call("wm focusmodel", w, focusmodel)
proc wm_focusmodel*(w: Widget): FocusModel =
  w.tk.call("wm focusmodel", w)
  parseEnum[FocusModel] w.tk.result
proc wm_forget*(w: Widget) = w.tk.call("wm forget", w)
proc wm_frame*(w: Widget) = w.tk.call("wm frame", w)
proc wm_geometry*(w: Widget, newGeometry: string) = w.tk.call("wm geometry", w, newGeometry)
proc wm_geometry*(w: Widget, width, height: int) = w.tk.call("wm geometry", w, $width & 'x' & $height)
proc wm_geometry*(w: Widget, x, y: int) =
  let
    xstr = if x >= 0: '+' & $x else: $x
    ystr = if y >= 0: '+' & $y else: $y

  w.tk.call("wm geometry", w, xstr & ystr)
proc wm_geometry*(w: Widget): tuple[width, height, x, y: int] =
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
      piece2 {.gensym.}= piece1[1].split(op2)

    result.height = piece1[0].parseInt()
    result.x = piece2[0].parseInt()
    result.y = piece2[1].parseInt()

    when op == "-":
      result.x = -result.x
    else:
      result.y = -result.y

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

# proc wm_grid*(w: Widget ?baseWidth baseHeight widthInc heightInc? 
# proc wm_group*(w: Widget ?pathName? 
# proc wm_iconbitmap*(w: Widget ?bitmap?
# # wm_iconbitmap window ?-default? ?image? 
# proc wm_iconify*(w: Widget 
# proc wm_iconmask*(w: Widget ?bitmap? 
# proc wm_iconname*(w: Widget ?newName? 
# proc wm_iconphoto*(w: Widget ?-default? image1 ?image2 ...? 
# proc wm_iconposition*(w: Widget ?x y? 
# proc wm_iconwindow*(w: Widget ?pathName? 
# proc wm_manage*(w: Widget 
# proc wm_maxsize*(w: Widget ?width height? 
# proc wm_minsize*(w: Widget ?width height? 
# proc wm_overrideredirect*(w: Widget ?boolean? 
# proc wm_positionfrom*(w: Widget ?who? 
# proc wm_protocol*(w: Widget ?name? ?command? 
# proc wm_resizable*(w: Widget ?width height? 
# proc wm_sizefrom*(w: Widget ?who? 
# proc wm_stackorder*(w: Widget ?isabove|isbelow window? 
# proc wm_state*(w: Widget ?newstate? 
# proc wm_title*(w: Widget ?string? 
# proc wm_transient*(w: Widget ?container? 
# proc wm_withdraw*(w: Widget 