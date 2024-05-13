import std/macros

import ./toargs

template configure*(w: typed, args: openArray[(string, string)]) =
  discard w.tk.call($w, "configure", args.toArgs())

template cget*(w: typed, option: string): string =
  w.tk.call($w, "cget", {option: " "}.toArgs())

macro call*(w: typed, args: varargs[string, `$`]) =
  result = newCall(newDotExpr(newDotExpr(w, ident"tk"), ident"call"))

  result.add newCall(ident"$", w)

  for arg in args:
    result.add arg
