import std/strutils

import ../../utils/genname
import ../../../nimtk
import ../widget
import ./widget

type
  Separator* = ref object of TtkWidget

proc isSeparator*(w: Widget): bool = "separator" in w.pathname.split('.')[^1]

proc newSeparator*(parent: Widget, configuration: openArray[(string, string)] = {:}): Separator =
  new result

  result.pathname = pathname(parent.pathname, genName("separator_"))
  result.tk = parent.tk

  result.tk.call("ttk::separator", result.pathname)
  
  if configuration.len > 0:
    result.configure(configuration)
