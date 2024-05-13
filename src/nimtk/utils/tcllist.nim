## Module to convert Nim types into Tcl lists. All exported functions do this.

import std/sequtils
import std/strutils

import nimtcl

import ../../nimtk
import ./escaping

proc wrap(insa: string): string {.inline.} = '{' & insa & '}'

proc toTclList*(padding: tuple): string =
  "{$1 $2}" % [$padding[0], $padding[1]]

proc toTclList*[T](arr: openArray[T]): string =
  arr.join(" ").wrap()

proc toTclList*[T](slice: Slice[T]): string =
  slice.toSeq().join(" ").wrap()

proc toTclList*(_: BlankOption): string = ""

proc toTclList*[T](padding: T and not openArray and not tuple and not Slice): string =
  result = $padding

proc fromTclList*(tk: Tk, list: string): seq[string] =
  # we use tk.interp so its not logged in nimtk debug
  tk.interp.eval(cstring "llength " & wrap list)

  let length = parseInt tk.result

  for listIndex in 0..<length:
    tk.interp.eval(cstring "lindex " & (wrap list) & (" " & $listIndex))
    
    result.add tk.result
