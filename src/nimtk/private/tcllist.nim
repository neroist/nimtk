import std/strutils

import nimtcl

import ../../nimtk

proc toTclList*(padding: int or float or string): string =
  $padding

proc toTclList*(padding: tuple): string =
  "{$1 $2}" % [$padding[0], $padding[1]]

proc toTclList*[T](arr: openArray[T]): string =
  # '{' & arr.mapIt($(it).tclEscape()).join(" ") & '}'
  '{' & arr.join(" ") & '}'

proc toTclList*[T](slice: Slice[T]): string =
  var arr: seq[T]

  for i in slice:
    arr.add i

  arr.toTclList()

proc wrap(insa: string): string {.inline.} = '{' & insa & '}'

proc fromTclList*(tk: Tk, list: string): seq[string] =
  ## Convert Tcl list to Nim seq

  # we use tk.interp so its not logged in nimtk debug
  tk.interp.eval(cstring "llength " & wrap list)

  let length = parseInt tk.result

  for listIndex in 0..<length:
    tk.interp.eval(cstring "lindex " & (wrap list) & (" " & $listIndex))
    
    result.add tk.result
