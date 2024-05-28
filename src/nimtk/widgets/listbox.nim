import std/sequtils
import std/strutils
import std/colors

import ../utils/escaping
import ../utils/tclcolor
import ../utils/tcllist
import ../utils/genname
import ../utils/toargs
import ../utils/alias
import ../variables
import ../../nimtk
import ./widget

type
  Listbox* = ref object of Widget

  Index = string or int

proc isListbox*(w: Widget): bool = "listbox" in w.pathname.split('.')[^1]

proc newListbox*(parent: Widget, texts: openArray[string] = [], configuration: openArray[(string, string)] = {:}): Listbox =
  new result

  result.pathname = pathname(parent.pathname, genName("listbox_"))
  result.tk = parent.tk

  result.tk.call("listbox", result.pathname)

  if texts.len > 0:
    for text in texts:
      result.tk.call($result, "insert", "end", tclEscape text)
  
  if configuration.len > 0:
    result.configure(configuration)

proc activate*(l: Listbox, index: Index) = l.call("activate", index)
proc bbox*(l: Listbox, index: Index): tuple[offsetX, offsetY, width, height: int] =
  l.call("bbox", index)

  if l.tk.result.len == 0:
    return

  let nums = l.tk.result.split()

  result.offsetX = nums[0].parseInt()
  result.offsetY = nums[1].parseInt()
  result.width = nums[2].parseInt()
  result.height = nums[3].parseInt()
proc curselection*(l: Listbox): seq[int] =
  l.call("curselection")

  # this relies on the implicit return of an empty seq
  # if this turns out to be false
  if l.tk.result.len != 0:
    return l.tk.result
      .split(' ')
      .map(parseInt)
proc delete*(l: Listbox, rng: Slice[int]) = l.call("delete", rng.a, rng.b)
proc delete*[I1, I2: Index](l: Listbox, first: I1, last: I2) = l.call("delete", first, last)
proc delete*(l: Listbox, first: Index) = l.call("delete", first)
proc get*(l: Listbox, rng: Slice[int]): seq[string] {.alias: "[]".} = l.tk.fromTclList l.call("get", rng.a, rng.b)
proc get*[I1, I2: Index](l: Listbox, first: I1, last: I2): seq[string] = l.tk.fromTclList l.call("get", first, last)
proc get*(l: Listbox, first: Index): string {.alias: "[]".} = l.call("get", first)
proc index*(l: Listbox, index: Index): int = parseInt l.call("index", $index)
proc insert*(l: Listbox, index: Index, elements: varargs[string]) {.alias: "[]=".} = l.call("insert", index, elements.map(tclEscape).join())
proc add*(l: Listbox, elements: varargs[string]) = l.insert("end", elements)
proc itemcget*(l: Listbox, index: Index, option: string): Color = fromTclColor l, l.call("itemcget", index, {option: " "}.toArgs())
proc itemconfigure*(
  l: Listbox,
  index: Index,
  background: Color or BlankOption = blankOption,
  foreground: Color or BlankOption = blankOption,
  selectbackground: Color or BlankOption = blankOption,
  selectforeground: Color or BlankOption = blankOption
) =
  l.tk.call(
    $l,
    "itemconfigure",
    index,
    {
      "background": $background,
      "foreground": $foreground,
      "selectbackground": $selectbackground,
      "selectforeground": $selectforeground
    }.toArgs()
  )
proc itemconfigure*(
  l: Listbox,
  indices: Slice[int],
  background: Color or BlankOption = blankOption,
  foreground: Color or BlankOption = blankOption,
  selectbackground: Color or BlankOption = blankOption,
  selectforeground: Color or BlankOption = blankOption
) =
  for idx in indices:
    l.itemconfigure(idx, background, foreground, selectbackground, selectforeground)
proc itemconfigure*[I1, I2: Index](
  l: Listbox,
  first: I1, last: I2,
  background: Color or BlankOption = blankOption,
  foreground: Color or BlankOption = blankOption,
  selectbackground: Color or BlankOption = blankOption,
  selectforeground: Color or BlankOption = blankOption
) {.alias: "itemconfigureRange".} =
  var (firstIdx, lastIdx) = (l.index(first), l.index(last))

  if last.normalize() == "end":
    dec lastIdx

  for idx in firstIdx..lastIdx:
    l.itemconfigure(idx, background, foreground, selectbackground, selectforeground)
proc nearest*(l: Listbox, y: int): int = parseInt l.call("nearest", y)
proc scanMark*(l: Listbox, x: int) = l.call("scan mark", x)
proc scanDragTo*(l: Listbox, x: int) = l.call("scan dragto", x)
proc see*(l: Listbox, index: Index) = l.call("see", index)
proc selectionAnchor*(l: Listbox, index: Index) = l.call("selection anchor", index)
proc selectionClear*(l: Listbox, rng: Slice[int]) = l.call("selection clear", rng.a, rng.b)
proc selectionClear*[I1, I2: Index](l: Listbox, first: I1, last: I2 = "end") = l.call("selection clear", first, last)
proc selectionIncludes*(l: Listbox, index: Index): bool = l.call("selection includes ", index) == "1"
proc selectionSet*(l: Listbox, index: Index) {.alias: "selection=".} = l.call("selection set", index)
proc selectionSet*(l: Listbox, rng: Slice[int]) {.alias: "selection=".} = l.call("selection set", rng.a, rng.b)
proc selectionSet*[I1, I2: Index](l: Listbox, first: I1, last: I2 = "end") {.alias: "selection=".} = l.call("selection set", first, last)
proc selectionGet*(l: Listbox): seq[string] {.alias: "selection".} =
  let cursel = l.curselection

  if cursel.len == 0:
    return @[]

  for selectionIndex in cursel:
    result.add l.get(selectionIndex)
proc size*(l: Listbox): int {.alias: "len".} = parseInt l.call("size")
proc xview*(l: Listbox): array[2, float] =
  l.call("xview")

  let res = l.tk.result.split(' ')

  result[0] = parseFloat res[0]
  result[1] = parseFloat res[1]
proc xview*(l: Listbox, index: Index) = l.call("xview", index)
proc xviewMoveto*(l: Listbox, fraction: 0.0..1.0) = l.call("xview moveto", fraction)
proc xviewScroll*(l: Listbox, number: int, what: string) = l.call("xview scroll", number, tclEscape what)
proc yview*(l: Listbox): array[2, float] =
  l.call("xview")

  let res = l.tk.result.split(' ')

  result[0] = parseFloat res[0]
  result[1] = parseFloat res[1]
proc yview*(l: Listbox, index: Index) = l.call("xview", index)
proc yviewMoveto*(l: Listbox, fraction: 0.0..1.0) = l.call("xview moveto", fraction)
proc yviewScroll*(l: Listbox, number: int, what: string) = l.call("xview scroll", number, tclEscape what)

proc `activestyle=`*(w: Widget, activestyle: ActiveStyle) = w.configure({"activestyle": $activestyle})
proc `height=`*(l: Listbox, height: int) = l.configure({"height": $height})
proc `listvariable=`*(w: Widget, listvariable: TkVar) = w.configure({"listvariable": listvariable.varname})
proc `selectmode=`*(w: Widget, selectmode: SelectMode) = w.configure({"selectmode": $selectmode})
proc `state=`*(l: Listbox, state: WidgetState) = l.configure({"state": $state})
proc `width=`*(l: Listbox, width: int) = l.configure({"width": $width})

proc activestyle*(w: Widget): ActiveStyle = parseEnum[ActiveStyle] w.cget("activestyle")
proc height*(l: Listbox): int = parseInt l.cget("height")
proc listvariable*(w: Widget): TkVar = createTkVar w.tk, w.cget("listvariable")
proc state*(l: Listbox): WidgetState = parseEnum[WidgetState] l.cget("state")
proc selectmode*(l: Listbox): SelectMode = parseEnum[SelectMode] l.cget("selectmode")
proc width*(l: Listbox): int = parseInt l.cget("width")
