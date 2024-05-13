import std/sequtils
import std/strutils
import std/colors

import ../utils/escaping
import ../utils/tclcolor
import ../utils/genname
import ../utils/toargs
import ../utils/alias
import ../../nimtk
import ./widget

type
  PanedWindow* = ref object of Widget

proc isPanedWindow*(w: Widget): bool = "panedwindow" in w.pathname.split('.')[^1]

proc newPanedWindow*(parent: Widget, orient: WidgetOrientation = WidgetOrientation.Horizontal, configuration: openArray[(string, string)] = {:}): PanedWindow =
  new result

  result.pathname = pathname(parent.pathname, genName("panedwindow_"))
  result.tk = parent.tk

  result.tk.call("panedwindow", result.pathname, {"orient": $orient}.toArgs)

  if configuration.len > 0:
    result.configure(configuration)

proc add*(p: PanedWindow, windows: varargs[Widget]) = p.tk.call($p, "add", windows.map(`$`).join(" "))
proc forget*(p: PanedWindow, windows: varargs[Widget]) = p.tk.call($p, "forget", windows.map(`$`).join(" "))
proc identify*(p: PanedWindow, x, y: int): tuple[index: int, kind: string] =
  let res = p.tk.call($p, "identify", x, y).split(' ')

  result.index = res[0].parseInt()
  result.kind = res[1]
proc panecget*(p: PanedWindow, window: Widget, option: string): string = p.tk.call($p, "panecget", window, option)
proc paneafter*(p: PanedWindow, window: Widget): Widget {.inline.} = p.tk.newWidgetFromPathname p.panecget("after")
proc panebefore*(p: PanedWindow, window: Widget): Widget {.inline.} = p.tk.newWidgetFromPathname p.panecget("before")
proc paneheight*(p: PanedWindow, window: Widget): string {.inline.} = p.panecget("height")
proc panehide*(p: PanedWindow, window: Widget): bool {.inline.} = parseBool p.panecget("hide")
proc paneminsize*(p: PanedWindow, window: Widget): string {.inline.} = p.panecget("minsize")
proc panepadx*(p: PanedWindow, window: Widget): string {.inline.} = p.panecget("padx")
proc panepady*(p: PanedWindow, window: Widget): string {.inline.} = p.panecget("pady")
proc panesticky*(p: PanedWindow, window: Widget): string {.inline.} = p.panecget("sticky")
proc panestretch*(p: PanedWindow, window: Widget): PaneStretch {.inline.} = parseEnum[PaneStretch] p.panecget("stretch")
proc panewidth*(p: PanedWindow, window: Widget): string {.inline.} = p.panecget("width")
proc paneconfigure*(
  p: PanedWindow,
  window: Widget,
  
  after: Widget = nil,
  before: Widget = nil,
  height: string or int or float or BlankOption = blankOption,
  hide: bool or BlankOption = blankOption,
  minsize: string or int or float or BlankOption = blankOption,
  padx: string or int or float or BlankOption = blankOption,
  pady: string or int or float or BlankOption = blankOption,
  sticky: openArray[char] or BlankOption = blankOption,
  stretch: PaneStretch or BlankOption = blankOption,
  width: string or int or float or BlankOption = blankOption
) = 
  p.tk.call(
    $p,
    "paneconfigure",
    window,
    {
      "after": $after,
      "before": $before,
      "height": tclEscape height,
      "hide": tclEscape hide,
      "minsize": tclEscape minsize,
      "padx": tclEscape padx,
      "pady": tclEscape pady,
      "sticky": tclEscape sticky,
      "stretch": $stretch,
      "width": tclEscape width
    }
  )
proc panes*(p: PanedWindow): seq[Widget] =
  let res = p.tk.call($p, "panes").split(' ')

  for i in res:
    result.add(p.tk.newWidgetFromPathname i)
proc `[]`*(p: PanedWindow, idx: int): Widget {.inline.} = p.panes[idx]
proc proxyCoord*(p: PanedWindow): tuple[x, y: int] =
  let res = p.tk.call($p, "proxy coord").split(' ').map(parseInt)

  result.x = res[0]
  result.y = res[1]
proc proxyForget*(p: PanedWindow) = p.tk.call($p, "proxy forget")
proc proxyPlace*(p: PanedWindow, x, y: int) = p.tk.call($p, "proxy place", x, y)
proc sashCoord*(p: PanedWindow, index: int): tuple[x, y: int] =
  let res = p.tk.call($p, "proxy coord", tclEscape $index).split(' ').map(parseInt)

  result.x = res[0]
  result.y = res[1]
proc shashDragto*(p: PanedWindow, index: int, x, y: int) = p.tk.call($p, "proxy dragto", tclEscape $index, x, y)
proc shashMark*(p: PanedWindow, index: int, x, y: int) = p.tk.call($p, "proxy mark", tclEscape $index, x, y)
proc shashPlace*(p: PanedWindow, index: int, x, y: int) = p.tk.call($p, "proxy place", tclEscape $index, x, y)

proc `handlepad=`*(p: PanedWindow, handlepad: int or string or float) = p.configure({"handlepad": tclEscape $handlepad})
proc `handlesize=`*(p: PanedWindow, handlesize: int or string or float) = p.configure({"handlesize": tclEscape $handlesize})
proc `height=`*(p: PanedWindow, height: int or string or float) = p.configure({"height": tclEscape $height})
proc `opaqueresize=`*(p: PanedWindow, opaqueresize: bool) = p.configure({"opaqueresize": $opaqueresize})
proc `proxybackground=`*(p: PanedWindow, proxybackground: Color) = p.configure({"proxybackground": $proxybackground})
proc `proxyborderwidth=`*(p: PanedWindow, proxyborderwidth: int or string or float) = p.configure({"proxyborderwidth": tclEscape $proxyborderwidth})
proc `proxyrelief=`*(p: PanedWindow, proxyrelief: WidgetRelief) = p.configure({"proxyrelief": $proxyrelief})
proc `sashcursor=`*(p: PanedWindow, sashcursor: Cursor or string) = p.configure({"sashcursor": tclEscape $sashcursor})
proc `sashpad=`*(p: PanedWindow, sashpad: int or string or float) = p.configure({"sashpad": tclEscape $sashpad})
proc `sashrelief=`*(p: PanedWindow, sashrelief: WidgetRelief) = p.configure({"sashrelief": $sashrelief})
proc `sashwidth=`*(p: PanedWindow, sashwidth: int or string or float) = p.configure({"sashwidth": tclEscape $sashwidth})
proc `showhandle=`*(p: PanedWindow, showhandle: bool) = p.configure({"showhandle": $showhandle})
proc `width=`*(p: PanedWindow, width: int or string or float) = p.configure({"width": tclEscape $width})

proc handlepad*(p: PanedWindow): string = p.cget("handlepad")
proc handlesize*(p: PanedWindow): string = p.cget("handlesize")
proc height*(p: PanedWindow): string = p.cget("height")
proc opaqueresize*(p: PanedWindow): bool = p.cget("opaqueresize") == "1"
proc proxybackground*(p: PanedWindow): Color = parseColor p.cget("proxybackground")
proc proxyborderwidth*(p: PanedWindow): string = p.cget("proxyborderwidth")
proc proxyrelief*(p: PanedWindow): WidgetRelief = parseEnum[WidgetRelief] p.cget("proxyrelief")
proc sashcursor*(p: PanedWindow): Cursor = parseEnum[Cursor] p.cget("sashcursor")
proc sashpad*(p: PanedWindow): string = p.cget("sashpad")
proc sashrelief*(p: PanedWindow): WidgetRelief = parseEnum[WidgetRelief] p.cget("sashrelief")
proc sashwidth*(p: PanedWindow): string = p.cget("sashwidth")
proc showhandle*(p: PanedWindow): bool = p.cget("showhandle") == "1"
proc width*(p: PanedWindow): string = p.cget("width")

