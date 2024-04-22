import std/strutils
import std/colors

import ./widgets/widget
import ./private/alias
import ../nimtk
import ./wm

# what the fuck is a "decimal string" do you mean "integer"?????? tf
proc winfo_atom*(w: Widget, name: string): int {.alias: "atom".} = parseInt w.tk.call("winfo atom", "-displayof", w, name)
proc winfo_atomname*(w: Widget, id: int): string {.alias: "atomname".} = w.tk.call("winfo atomname", "-displayof", w, id)
proc winfo_cells*(w: Widget): int {.alias: "cells".} = parseInt w.tk.call("winfo cells", w)
proc winfo_children*(w: Widget): seq[Widget] {.alias: "children".} =
  w.tk.call("winfo children", w)

  for pathname in w.tk.result.split(" "):
    result.add w.tk.newWidgetFromPathname(pathname)
proc winfo_class*(w: Widget): string {.alias: "class".} = w.tk.call("winfo class", w)
proc winfo_colormapfull*(w: Widget): bool {.alias: "colormapfull".} = w.tk.call("winfo colormapfull", w) == "1"
proc winfo_containing*(w: Widget, rootX, rootY: int or float or string): Widget {.alias: "containing".} =
  w.tk.call("winfo containing", "-displayof", w, rootX, rootY)

  if w.tk.result.len == 0: return nil
  else: return w.tk.newWidgetFromPathname w.tk.result
proc winfo_depth*(w: Widget): int {.alias: "depth".} = parseInt w.tk.call("winfo depth", w)
proc winfo_exists*(w: Widget): bool {.alias: "exists".} = w.tk.call("winfo exists", w) == "1"
proc winfo_fpixels*(w: Widget, number: int or float or string): float {.alias: "fpixels".} = parseFloat w.tk.call("winfo fpixels", w)
proc winfo_geometry*(w: Widget): tuple[width, height, x, y: int] {.alias: "geometry".} =
  w.tk.call("winfo geometry", w)

  let res = w.tk.result.split("x")

  result.width = res[0].parseInt()

  lucky("+")
proc winfo_height*(w: Widget): int {.alias: "height".} = parseInt w.tk.call("winfo height", w)
proc winfo_id*(w: Widget): int {.alias: "id".} = parseHexInt w.tk.call("winfo id", w)
proc winfo_interps*(w: Widget): seq[string] {.alias: "interps".} = split w.tk.call("winfo interps", "-displayof", w), ' '
proc winfo_ismapped*(w: Widget): bool {.alias: "ismapped".} = w.tk.call("winfo ismapped", w) == "1"
proc winfo_manager*(w: Widget): string {.alias: "manager".} = w.tk.call("winfo manager", w)
proc winfo_name*(w: Widget): string {.alias: "name".} = w.tk.call("winfo name", w)
proc winfo_parent*(w: Widget): Widget {.alias: "parent".} = w.tk.newWidgetFromPathname w.tk.call("winfo parent", w)
proc winfo_pathname*(w: Widget, id: int): string {.alias: "pathname".} = w.tk.call("winfo pathname", "-displayof", w, id)
proc winfo_pixels*(w: Widget, number: int or float or string): int {.alias: "pixels".} = parseInt w.tk.call("winfo pixels", w)
proc winfo_pointerx*(w: Widget): int {.alias: "pointerx".} = parseInt w.tk.call("winfo pointerx", w)
proc winfo_pointerxy*(w: Widget): tuple[x, y: int] {.alias: "pointerxy".} =
  w.tk.call("winfo pointerxy", w)

  let res = w.tk.result.split(' ')

  result.x = parseInt res[0]
  result.y = parseInt res[1]
proc winfo_pointery*(w: Widget): int {.alias: "pointery".} = parseInt w.tk.call("winfo pointery", w)
proc winfo_reqheight*(w: Widget): int {.alias: "reqheight".} = parseInt w.tk.call("winfo reqheight", w)
proc winfo_reqwidth*(w: Widget): int {.alias: "reqwidth".} = parseInt w.tk.call("winfo reqwidth", w)
proc winfo_rgb*(w: Widget, color: Color): tuple[r, g, b: int] {.alias: "rgb".} =
  w.tk.call("winfo rgb", w)

  let res = w.tk.result.split(' ')

  result.r = parseInt res[0]
  result.g = parseInt res[1]
  result.b = parseInt res[2]
proc winfo_rootx*(w: Widget): int {.alias: "rootx".} = parseInt w.tk.call("winfo rootx", w)
proc winfo_rooty*(w: Widget): int {.alias: "rooty".} = parseInt w.tk.call("winfo rooty", w)
proc winfo_screen*(w: Widget): tuple[displayName: string, screenIndex: int] {.alias: "screen".} =
  w.tk.call("winfo screen", w)

  let res = w.tk.result.split(' ')

  result.displayName = res[0]
  result.screenIndex = parseInt res[1]
proc winfo_screencells*(w: Widget): int {.alias: "screencells".} = parseInt w.tk.call("winfo screencells", w)
proc winfo_screendepth*(w: Widget): int {.alias: "screendepth".} = parseInt w.tk.call("winfo screendepth", w)
proc winfo_screenheight*(w: Widget): int {.alias: "screenheight".} = parseInt w.tk.call("winfo screenheight", w)
proc winfo_screenmmheight*(w: Widget): int {.alias: "screenmmheight".} = parseInt w.tk.call("winfo screenmmheight", w)
proc winfo_screenmmwidth*(w: Widget): int {.alias: "screenmmwidth".} = parseInt w.tk.call("winfo screenmmwidth", w)
proc winfo_screenvisual*(w: Widget): VisualClass {.alias: "screenvisual".} = parseEnum[VisualClass] w.tk.call("winfo screenvisual", w)
proc winfo_screenwidth*(w: Widget): int {.alias: "screenwidth".} = parseInt w.tk.call("winfo screenwidth", w)
proc winfo_server*(w: Widget): string {.alias: "server".} = w.tk.call("winfo server", w)
proc winfo_toplevel*(w: Widget): Widget {.alias: "toplevel".} = w.tk.newWidgetFromPathname w.tk.call("winfo toplevel", w)
proc winfo_viewable*(w: Widget): bool {.alias: "viewable".} = w.tk.call("winfo viewable", w) == "1"
proc winfo_visual*(w: Widget): VisualClass {.alias: "visual".} = parseEnum[VisualClass] w.tk.call("winfo visual", w)
proc winfo_visualid*(w: Widget): int {.alias: "visualid".} = parseHexInt w.tk.call("winfo visualid", w)
proc winfo_visualsavailable*(w: Widget, includeids: bool = true): tuple[class: VisualClass, depth: int, id: int] {.alias: "visualsavailable".} =
  w.tk.call("winfo visualsavailable", w) 

  let res = w.tk.result.split(' ')

  result.class = parseEnum[VisualClass] res[0]
  result.depth = parseInt res[1]
  
  if includeids:
    result.id = parseHexInt res[2]
proc winfo_vrootheight*(w: Widget): int {.alias: "vrootheight".} = parseInt w.tk.call("winfo vrootheight", w)
proc winfo_vrootwidth*(w: Widget): int {.alias: "vrootwidth".} = parseInt w.tk.call("winfo vrootwidth", w)
proc winfo_vrootx*(w: Widget): int {.alias: "vrootx".} = parseInt w.tk.call("winfo vrootx", w)
proc winfo_vrooty*(w: Widget): int {.alias: "vrooty".} = parseInt w.tk.call("winfo vrooty", w)
proc winfo_width*(w: Widget): int {.alias: "width".} = parseInt w.tk.call("winfo width", w)
proc winfo_x*(w: Widget): int {.alias: "x".} = parseInt w.tk.call("winfo x", w)
proc winfo_y*(w: Widget): int {.alias: "y".} = parseInt w.tk.call("winfo y", w)
