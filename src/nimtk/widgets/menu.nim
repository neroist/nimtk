import std/sequtils
import std/strutils
import std/colors

import ../private/escaping
import ../private/tclcolor
import ../private/genname
import ../private/toargs
import ../variables
import ../../nimtk
import ../images
import ./widget
import ../font

type
  Menu* = ref object of Widget
  MenuEntry* = object #? should this be a ref object
    menu: Menu
    index: int

  Index = int or string

proc index*(m: Menu, index: Index): int

proc isMenu*(m: Menu): bool = "menu" in m.pathname.split('.')[^1]

proc newMenu*(parent: Widget, title: string = "", configuration: openArray[(string, string)] = {:}): Menu =
  new result

  result.pathname = pathname(parent.pathname, genName("menu_"))
  result.tk = parent.tk

  result.tk.call("menu", result.pathname)
  
  if title.len > 0:
    result.configure({"title": tclEscape title})

  if configuration.len > 0:
    result.configure(configuration)

proc setPostCommand*(m: Menu, command: TkGenericCommand) =
  let name = genName("menu_postcommand_")
  
  m.tk.registerCmd(m, name, command)

  m.configure({"command": name})
proc `postcommand=`*(m: Menu, command: TkGenericCommand) = m.setPostCommand(command)
proc setTearOffCommand*(m: Menu, command: TkWidgetCommand) =
  let name = genName("menu_tearoffcommand_")
  
  m.tk.registerCmd(m, name, command)

  m.configure({"command": name})
proc `tearoffcommand=`*(m: Menu, tearoffcommand: TkWidgetCommand) = m.setTearOffCommand(tearoffcommand)
proc `selectcolor=`*(m: Menu, selectcolor: Color) = m.configure({"selectcolor": $selectcolor})
proc `tearoff=`*(m: Menu, tearoff: bool) = m.configure({"tearoff": $tearoff})
proc `title=`*(m: Menu, title: string) = m.configure({"title": title})
proc `type=`*(m: Menu, `type`: MenuType) = m.configure({"type": $`type`})

proc selectcolor*(m: Menu): Color = m.fromTclColor m.cget("selectcolor")
proc tearoff*(m: Menu): bool = m.cget("tearoff") == "1"
proc title*(m: Menu): string = m.cget("title")
proc `type`*(m: Menu): MenuType = parseEnum[MenuType] m.cget("type")

# menuentry stuffs

proc `[]`*(m: Menu, index: Index): MenuEntry =
  result.menu = m
  result.index = m.index(index)
proc `[]`*(m: Menu, index: BackwardsIndex): MenuEntry =
  result.menu = m
  result.index = m.index(int(index) - 1)

proc add*(m: Menu, `type`: MenuEntryType or string): MenuEntry {.discardable.} = m.tk.call($m, "add", tclEscape $`type`); m[^1]
proc addCascade*(m: Menu, label: string = ""): MenuEntry {.discardable.} = m.tk.call($m, "add", "cascade", {"label": tclEscape label}.toArgs); m[^1]
proc addCheckbutton*(m: Menu, label: string = ""): MenuEntry {.discardable.} = m.tk.call($m, "add", "checkbutton", {"label": tclEscape label}.toArgs); m[^1]
proc addCommand*(m: Menu, label: string = ""): MenuEntry {.discardable.} = m.tk.call($m, "add", "command", {"label": tclEscape label}.toArgs); m[^1]
proc addRadiobutton*(m: Menu, label: string = ""): MenuEntry {.discardable.} = m.tk.call($m, "add", "radiobutton", {"label": tclEscape label}.toArgs); m[^1]
proc addSeparator*(m: Menu): MenuEntry {.discardable.} = m.tk.call($m, "add", "separator"); m[^1]
proc clone*(m: Menu, menu: var Menu, cloneType: MenuType or string = "") = m.tk.call($m, "clone", menu, tclEscape cloneType)
proc delete*(m: Menu, index1: Index) = m.tk.call($m, "delete", tclEscape $index1)
proc delete*[I1, I2: Index](m: Menu, index1: I1, index2: I2) = m.tk.call($m, "delete", tclEscape $index1, tclEscape $index2)
proc delete*(m: Menu, indexes: Slice[int]) {.inline.} = m.delete(indexes.a, indexes.b)
proc entrycget*(m: Menu, index: int, option: string): string = m.tk.call($m, "entrycget", tclEscape $index, tclEscape option)
proc entryconfigure*(m: Menu, index: Index, options: openArray[(string, string)] = []): string {.discardable.} = m.tk.call($m, "entryconfigure", tclEscape $index, options.mapIt((it[0], tclEscape it[1])).toArgs())
proc index*(m: Menu, index: Index): int =
  # if index is "none", return -1
  m.tk.call($m, "index", tclEscape $index)

  if m.tk.result == "none":
    return -1
  else:
    return parseInt(m.tk.result)
proc insert*(m: Menu, index: Index, `type`: MenuEntryType or string): MenuEntry = m.tk.call($m, "insert", tclEscape $index, tclEscape $`type`); m[^1]
proc insertCascade*(m: Menu, index: Index, label: string = ""): MenuEntry {.discardable.} = m.tk.call($m, "insert", tclEscape $index, "cascade", {"label": tclEscape label}.toArgs); m[^1]
proc insertCheckbutton*(m: Menu, index: Index, label: string = ""): MenuEntry {.discardable.} = m.tk.call($m, "insert", tclEscape $index, "checkbutton", {"label": tclEscape label}.toArgs); m[^1]
proc insertCommand*(m: Menu, index: Index, label: string = ""): MenuEntry {.discardable.} = m.tk.call($m, "insert", tclEscape $index, "command", {"label": tclEscape label}.toArgs); m[^1]
proc insertRadiobutton*(m: Menu, index: Index, label: string = ""): MenuEntry {.discardable.} = m.tk.call($m, "insert", tclEscape $index, "radiobutton", {"label": tclEscape label}.toArgs); m[^1]
proc insertSeparator*(m: Menu, index: Index): MenuEntry {.discardable.} = m.tk.call($m, "insert", tclEscape $index, "separator"); m[^1]
proc invoke*(m: Menu, index: Index) = m.tk.call($m, "invoke", tclEscape $index)
proc post*(m: Menu, x, y: int, index: Index) = m.tk.call($m, "post", x, y, tclEscape $index)
proc post*(m: Menu, x, y: int) = m.tk.call($m, "post", x, y)
proc postcascade*(m: Menu, index: Index) = m.tk.call($m, "postcascade", tclEscape $index)
proc type*(m: Menu, index: Index): MenuEntryType = parseEnum[MenuEntryType] m.tk.call($m, "type", tclEscape $index)
proc unpost*(m: Menu) = m.tk.call($m, "unpost")
proc xposition*(m: Menu, index: Index): int = parseInt m.tk.call($m, "xposition", tclEscape $index)
proc yposition*(m: Menu, index: Index): int = parseInt m.tk.call($m, "yposition", tclEscape $index)

# --- menuentry procs
proc cget*(m: MenuEntry, option: string): string = m.menu.tk.call($m.menu, "entrycget", m.index, tclEscape option)
proc configure*(m: MenuEntry, options: openArray[(string, string)] = []): string {.discardable.} = m.menu.tk.call($m.menu, "entryconfigure", m.index, options.toArgs())
proc delete*(m: MenuEntry) = m.menu.tk.call($m.menu, "delete", m.index)
proc invoke*(m: MenuEntry) = m.menu.tk.call($m.menu, "invoke", m.index)
proc post*(m: MenuEntry, x, y: int) = m.menu.tk.call($m.menu, "post", x, y, m.index)
proc type*(m: MenuEntry): MenuEntryType = parseEnum[MenuEntryType] m.menu.tk.call($m.menu, "type", m.index)
proc xposition*(m: MenuEntry): int = parseInt m.menu.tk.call($m.menu, "xposition", m.index)
proc yposition*(m: MenuEntry): int = parseInt m.menu.tk.call($m.menu, "yposition", m.index)

# -- menuentry getters & setters
proc setCommand*(m: MenuEntry, command: TkGenericCommand) =
  let name = genName("menuentry_command_")
  
  m.menu.tk.registerCmd(nil, name, command)

  m.configure({"command": name})

proc `activebackground=`*(m: MenuEntry, activebackground: Color) = m.configure({"activebackground": $activebackground})
proc `activeforeground=`*(m: MenuEntry, activeforeground: Color) = m.configure({"activeforeground": $activeforeground})
proc `accelerator=`*(m: MenuEntry, accelerator: string) = m.configure({"accelerator": tclEscape $accelerator})
proc `background=`*(m: MenuEntry, background: Color) = m.configure({"background": $background})
proc `bitmap=`*(m: MenuEntry, bitmap: Bitmap or string) = m.configure({"bitmap": tclEscape $bitmap})
proc `columnbreak=`*(m: MenuEntry, columnbreak: bool) = m.configure({"columnbreak": $columnbreak})
proc `command=`*(m: MenuEntry, command: TkGenericCommand) = m.setCommand(command)
proc `compound=`*(m: MenuEntry, compound: WidgetCompound) = m.configure({"compound": $compound})
proc `font=`*(m: MenuEntry, font: Font) = m.configure({"font": $font})
proc `foreground=`*(m: MenuEntry, foreground: Color) = m.configure({"foreground": $foreground})
proc `hidemargin=`*(m: MenuEntry, hidemargin: bool) = m.configure({"hidemargin": $hidemargin})
# image
proc `indicatoron=`*(m: MenuEntry, indicatoron: bool) = m.configure({"indicatoron": $indicatoron})
proc `label=`*(m: MenuEntry, label: string) =  m.configure({"label": tclEscape label})
proc `menu=`*(m: MenuEntry, menu: Menu) = m.configure({"menu": $menu})
proc `offvalue=`*(m: MenuEntry, offvalue: bool or int or string) = m.configure({"offvalue": tclEscape $offvalue})
proc `onvalue=`*(m: MenuEntry, onvalue: bool or int or string) = m.configure({"onvalue": tclEscape $onvalue})
proc `selectcolor=`*(m: MenuEntry, selectcolor: Color) = m.configure({"selectcolor": $selectcolor})
# selectimage
proc `state=`*(m: MenuEntry, state: WidgetState) = m.configure({"state": $state})
proc `underline=`*(m: MenuEntry, underline: int) = m.configure({"underline": $underline})
proc `value=`*(m: MenuEntry, value: bool or int or string) = m.configure({"value": tclEscape $value})
proc `variable=`*(m: MenuEntry, variable: TkVar) = m.configure({"variable": variable.varname})

