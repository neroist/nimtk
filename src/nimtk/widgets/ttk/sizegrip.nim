import std/strutils

import ../../utils/genname
import ../../../nimtk
import ../widget
import ./widget

type
  Sizegrip* = ref object of TtkWidget

proc isSizegrip*(w: Widget): bool = "sizegrip" in w.pathname.split('.')[^1]

proc newSizegrip*(parent: Widget, configuration: openArray[(string, string)] = {:}): Sizegrip =
  new result

  result.pathname = pathname(parent.pathname, genName("sizegrip_"))
  result.tk = parent.tk

  result.tk.call("ttk::sizegrip", result.pathname)

  if configuration.len > 0:
    result.configure(configuration)
