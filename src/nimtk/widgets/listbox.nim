import std/strutils
import std/sequtils
import std/colors

import ../private/escaping
import ../private/toargs
import ../private/alias
import ../../nimtk
import ./widget

type
  Listbox* = ref object of Widget

  Index = string or int

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

proc activate*(l: Listbox, index: Index) = l.tk.call($l, "activate", index)
proc bbox*(l: Listbox, index: Index): tuple[offsetX, offsetY, width, height: int] =
  l.tk.call($l, "bbox", index)

  if l.tk.result.len == 0:
    return

  let nums = l.tk.result.split()

  result.offsetX = nums[0].parseInt()
  result.offsetY = nums[1].parseInt()
  result.width = nums[2].parseInt()
  result.height = nums[3].parseInt()
proc curselection*(l: Listbox): seq[int] =
  l.tk.call($l, "curselection")

  # this relies on the implicit return of an empty seq
  # if this turns out to be false
  if l.tk.result.len != 0:
    l.tk.result
      .split(' ')
      .map(parseInt)
proc delete*(l: Listbox, rng: Slice[int]) = l.tk.call($l, "delete", rng.a, rng.b)
proc delete*[I1, I2: Index](l: Listbox, first: I1, last: I2) = l.tk.call($l, "delete", first, last)
proc delete*(l: Listbox, first: Index) = l.tk.call($l, "delete", first)
proc get*(l: Listbox, rng: Slice[int]): seq[string] = l.tk.call($l, "get", rng.a, rng.b).split(' ')
proc get*[I1, I2: Index](l: Listbox, first: I1, last: I2): seq[string] = l.tk.call($l, "get", first, last).split(' ')
proc get*(l: Listbox, first: Index): string = l.tk.call($l, "get", first)
proc index*(l: Listbox, index: Index): int = parseInt l.tk.call($l, "index", $index)
proc insert*(l: Listbox, index: Index, elements: varargs[string]) =
  var safeElements: seq[string]

  for unsafeElement in elements:
    safeElements.add tclEscape unsafeElement

  l.tk.call($l, "insert", index, safeElements.join())
proc add*(l: Listbox, elements: varargs[string]) = l.insert("end", elements)
proc itemcget*(l: Listbox, index: Index, option: string): Color = fromTclColor l, l.tk.call($l, "itemcget", index, {option: " "}.toArgs())
proc itemconfigure*(
  l: Listbox,
  index: Index,
  background: Color or string = "",
  foreground: Color or string = "",
  selectbackground: Color or string = "",
  selectforeground: Color or string = ""
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
  background: Color or string = "",
  foreground: Color or string = "",
  selectbackground: Color or string = "",
  selectforeground: Color or string = ""
) =
  for idx in indices:
    l.itemconfigure(idx, background, foreground, selectbackground, selectforeground)
proc itemconfigure*[I1, I2: Index](
  l: Listbox,
  first: I1, last: I2,
  background: Color or string = "",
  foreground: Color or string = "",
  selectbackground: Color or string = "",
  selectforeground: Color or string = ""
) {.alias: "itemconfigureRange".} =
  var (firstIdx, lastIdx) = (l.index(first), l.index(last))

  if last.normalize() == "end":
    dec lastIdx

  for idx in firstIdx..lastIdx:
    l.itemconfigure(idx, background, foreground, selectbackground, selectforeground)
proc nearest*(l: Listbox, y: int): int = parseInt l.tk.call($l, "nearest", y)
proc scanMark*(l: Listbox, x: int) = l.tk.call($l, "scan mark", x)
proc scanDragTo*(l: Listbox, x: int) = l.tk.call($l, "scan dragto", x)
proc see*(l: Listbox, index: Index) = l.tk.call($l, "see", index)
proc selectionAnchor*(l: Listbox, index: Index) = l.tk.call($l, "selection anchor", index)
proc selectionClear*(l: Listbox, rng: Slice[int]) = l.tk.call($l, "selection clear", rng.a, rng.b)
proc selectionClear*[I1, I2: Index](l: Listbox, first: I1, last: I2 = "end") = l.tk.call($l, "selection clear", first, last)
proc selectionIncludes*(l: Listbox, index: Index): bool = l.tk.call($l, "selection includes ", index) == "1"
proc selectionSet*(l: Listbox, rng: Slice[int]) = l.tk.call($l, "selection set", rng.a, rng.b)
proc selectionSet*[I1, I2: Index](l: Listbox, first: I1, last: I2 = "end") = l.tk.call($l, "selection set", first, last)
proc size*(l: Listbox): int {.alias: "len".} = parseInt l.tk.call($l, "size")
proc xview*(l: Listbox): array[2, float] =
  l.tk.call($l, "xview")

  let res = l.tk.result.split(' ')

  result[0] = parseFloat res[0]
  result[1] = parseFloat res[1]
proc xview*(l: Listbox, index: Index) = l.tk.call($l, "xview", index)
proc xviewMoveto*(l: Listbox, fraction: 0.0..1.0) = l.tk.call($l, "xview moveto", fraction)
proc xviewScroll*(l: Listbox, number: int, what: string) = l.tk.call($l, "xview scroll", number, tclEscape what)
proc yview*(l: Listbox): array[2, float] =
  l.tk.call($l, "xview")

  let res = l.tk.result.split(' ')

  result[0] = parseFloat res[0]
  result[1] = parseFloat res[1]
proc yview*(l: Listbox, index: Index) = l.tk.call($l, "xview", index)
proc yviewMoveto*(l: Listbox, fraction: 0.0..1.0) = l.tk.call($l, "xview moveto", fraction)
proc yviewScroll*(l: Listbox, number: int, what: string) = l.tk.call($l, "xview scroll", number, tclEscape what)

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
