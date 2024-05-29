import std/strutils

import ../../utils/genname
import ../../utils/toargs
import ../../../nimtk
import ../widget
import ./widget

type
  Separator* = ref object of TtkWidget

proc isSeparator*(w: Widget): bool = "separator" in w.pathname.split('.')[^1]

proc newSeparator*(parent: Widget, orient: WidgetOrientation = woHorizontal, configuration: openArray[(string, string)] = {:}): Separator =
  new result

  result.pathname = pathname(parent.pathname, genName("separator_"))
  result.tk = parent.tk

  result.tk.call("ttk::separator", result.pathname, {"orient": $orient}.toArgs)
  
  if configuration.len > 0:
    result.configure(configuration)

proc newHorizontalSeparator*(parent: Widget, configuration: openArray[(string, string)] = {:}): Separator =
  newSeparator(parent, woHorizontal, configuration)

proc newVerticalSeparator*(parent: Widget, configuration: openArray[(string, string)] = {:}): Separator =
  newSeparator(parent, woVertical, configuration)
