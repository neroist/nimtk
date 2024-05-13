import std/strutils

import ../utils/escaping
import ../utils/genname
import ../../nimtk
import ./widget

type
  Label* = ref object of Widget

proc isLabel*(w: Widget): bool = "label" in w.pathname.split('.')[^1]

proc newLabel*(parent: Widget, text: string = ""): Label =
  new result

  result.pathname = pathname(parent.pathname, genName("label_"))
  result.tk = parent.tk

  result.tk.call("label", result.pathname)

  if text.len > 0:
    result.configure({"text": tclEscape text})

proc `height=`*(l: Label, height: string or float or int) = l.configure({"height": $height})
proc `state=`*(l: Label, state: LabelState) = l.configure({"state": $state})
proc `width=`*(l: Label, width: string or float or int) = l.configure({"width": $width})

proc height*(l: Label): string = l.cget("height")
proc state*(l: Label): LabelState = parseEnum[LabelState] l.cget("state")
proc width*(l: Label): string = l.cget("width")
