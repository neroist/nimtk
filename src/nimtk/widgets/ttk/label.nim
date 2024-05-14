import std/strutils

import ../../utils/escaping
import ../../utils/genname
import ../../../nimtk
import ../widget
import ./widget

type
  TtkLabel* = ref object of TtkWidget

proc isTtkLabel*(w: Widget): bool = "ttklabel" in w.pathname.split('.')[^1]

proc newTtkLabel*(parent: Widget, text: string = ""): TtkLabel =
  new result

  result.pathname = pathname(parent.pathname, genName("ttklabel_"))
  result.tk = parent.tk

  result.tk.call("ttk::label", result.pathname)

  if text.len > 0:
    result.configure({"text": tclEscape text})
