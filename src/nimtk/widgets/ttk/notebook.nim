import std/sequtils
import std/strutils

import ../../utils/escaping
import ../../utils/genname
import ../../utils/tcllist
import ../../utils/toargs
import ../../../nimtk
import ../../images
import ../widget
import ./widget

type
  Notebook* = ref object of TtkWidget
  Tab* = object
    notebook: Notebook
    index: int

  TabId = int or string or Widget

proc index*(n: Notebook, tabid: TabId): int

proc isNotebook*(m: Notebook): bool = "notebook" in m.pathname.split('.')[^1]

proc newNotebook*(parent: Widget, configuration: openArray[(string, string)] = {:}): Notebook =
  new result

  result.pathname = pathname(parent.pathname, genName("notebook_"))
  result.tk = parent.tk

  result.tk.call("ttk::notebook", result.pathname)

  if configuration.len > 0:
    result.configure(configuration)

proc `[]`*(n: Notebook, tabid: int): Tab =
  Tab(notebook: n, index: tabid)
proc `[]`*(n: Notebook, tabid: string or Widget): Tab =
  Tab(notebook: n, index: n.index(tabid))

proc add*(n: Notebook, window: Widget, options: openArray[(string, string)] = {:}): Tab {.discardable.} =
  n.call("add", window, toArgs options)

  result.notebook = n
  result.index = n.index("end") - 1
proc add*(n: Notebook, window: Widget, text: string, options: openArray[(string, string)] = {:}): Tab {.discardable.} =
  n.call("add", window, {"text": tclEscape text}.toArgs, toArgs options)

  result.notebook = n
  result.index = n.index("end") - 1
proc forget*(n: Notebook, tabid: TabId) = n.call("forget", tclEscape tabid)
proc hide*(n: Notebook, tabid: TabId) = n.call("hide", tclEscape tabid)
proc index*(n: Notebook, tabid: TabId): int = parseInt n.call("index", tclEscape tabid)
proc len*(n: Notebook): int = parseInt n.call("index", "end")
proc insert*(n: Notebook, pos: string or int or Widget, subwindow: Widget, options: openArray[(string, string)] = {:}): Tab {.discardable.} =
  n.call("insert", pos, subwindow, toArgs options)

  result.notebook = n
  result.index = n.index(subwindow)
proc insert*(n: Notebook, pos: string or int or Widget, subwindow: Widget, text: string, options: openArray[(string, string)] = {:}): Tab {.discardable.} =
  n.call("insert", pos, subwindow, {"text": tclEscape text}.toArgs, toArgs options)

  result.notebook = n
  result.index = n.index(subwindow)
proc select*(n: Notebook, tabid: TabId) = n.call("select", tabid)
proc select*(n: Notebook): Widget = newWidgetFromPathname n.tk, n.call("select")
proc tab*(n: Notebook, tabid: TabId, options: openArray[(string, string)]) = n.call("tab", tclEscape tabid, toArgs options)
proc tab*(n: Notebook, tabid: TabId, option: string): string = n.call("tab", tclEscape tabid, '-' & option)
proc tabs*(n: Notebook): seq[Widget] = n.call("tabs").split().mapIt(newWidgetFromPathname(n.tk, it))
proc enableTransversal*(n: Notebook) = n.tk.call("ttk::notebook::enableTraversal", n)

# tab procs
proc `state=`*(t: Tab, state: TabState) = t.notebook.tab(t.index, {"state": $state})
proc `sticky=`*(t: Tab, sticky: string or AnchorPosition) = t.notebook.tab(t.index, {"sticky": tclEscape sticky})
proc `padding=`*(t: Tab, padding: openArray[int]) = t.notebook.tab(t.index, {"padding": padding.toTclList()})
proc `padding=`*(t: Tab, padding: int) = t.notebook.tab(t.index, {"padding": padding.toTclList()})
proc `text=`*(t: Tab, text: string) = t.notebook.tab(t.index, {"text": tclEscape text})
proc `image=`*(t: Tab, image: Image) = t.notebook.tab(t.index, {"image": $image})
proc `compound=`*(t: Tab, compound: WidgetCompound) = t.notebook.tab(t.index, {"compound": $compound})
proc `underline=`*(t: Tab, underline: int) = t.notebook.tab(t.index, {"underline": $underline})

proc state*(t: Tab): TabState = parseEnum[TabState] t.notebook.tab(t.index, "state")
proc sticky*(t: Tab): AnchorPosition = parseEnum[AnchorPosition] t.notebook.tab(t.index, "sticky")
proc padding*(t: Tab): seq[int] = t.notebook.tab(t.index, "padding").split().map(parseInt)
proc text*(t: Tab): string = t.notebook.tab(t.index, "text")
proc image*(t: Tab): Image = createImage t.notebook.tk, t.notebook.tab(t.index, "image")
proc compound*(t: Tab): WidgetCompound = parseEnum[WidgetCompound] t.notebook.tab(t.index, "compound")
proc underline*(t: Tab): int = parseInt t.notebook.tab(t.index, "underline")

# notebook config
proc `height=`*(n: Notebook, height: int) = n.configure({"height": $height})
proc `width=`*(n: Notebook, width: int) = n.configure({"width": $width})

proc height*(n: Notebook): int = parseInt n.cget("height")
proc width*(n: Notebook): int = parseInt n.cget("width")
