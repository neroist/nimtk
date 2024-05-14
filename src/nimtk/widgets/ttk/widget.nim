import std/strutils

import ../../utils/escaping
import ../../utils/commands
import ../../../nimtk
import ../widget

type
  TtkWidget* = ref object of Widget


# -- -- options

proc `state=`*(w: TtkWidget, state: string) = w.configure({"state": state})
proc `width=`*(w: TtkWidget, width: string or float or int) = w.configure({"width": $width})

proc class*(w: TtkWidget): string = w.cget("class")
proc width*(w: TtkWidget): string = w.cget("width")


# -- -- commands

# -- identify element
proc identifyElement*(w: TtkWidget, x, y: int): string =
  w.call("identify element", x, y)

#  -- instate
proc instate*(w: TtkWidget, statespec: string, script: TkGenericCommand = nil): bool =
  # lets do Tk's behavior for it since theres no real reason to create a whole new command

  if script.isNil():
    return w.call("instate", tclEscape statespec) == "1"
  else:
    if w.instate(statespec, script=nil):
      script()

# -- state
proc state*(w: TtkWidget): string =
  w.call("state")

proc state*(w: TtkWidget, statespec: string) =
  w.call("state", tclEscape statespec)

# -- xview
proc xview*(w: TtkWidget): array[2, float] =
  w.call("xview")

  let res = w.tk.result.split(' ')

  result[0] = parseFloat res[0]
  result[1] = parseFloat res[1]

proc xview*(w: TtkWidget, index: int) =
  w.call("xview", index)

proc xviewMoveto*(w: TtkWidget, fraction: 0.0..1.0) =
  w.call("xview moveto", fraction)

proc xviewScroll*(w: TtkWidget, number: int, what: string) =
  w.call("xview scroll", number, tclEscape what)

# -- yview
proc yview*(w: TtkWidget): array[2, float] =
  w.call("xview")

  let res = w.tk.result.split(' ')

  result[0] = parseFloat res[0]
  result[1] = parseFloat res[1]

proc yview*(w: TtkWidget, index: int) =
  w.call("xview", index)

proc yviewMoveto*(w: TtkWidget, fraction: 0.0..1.0) =
  w.call("xview moveto", fraction)

proc yviewScroll*(w: TtkWidget, number: int, what: string) =
  w.call("xview scroll", number, tclEscape what)
