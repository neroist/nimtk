import std/strutils

proc toTclList*(padding: int or float or string): string =
  $padding

proc toTclList*(padding: tuple): string =
  "{$1 $2}" % [$padding[0], $padding[1]]

proc toTclList*[T](arr: openArray[T]): string =
  '{' & arr.join(" ") & '}'
