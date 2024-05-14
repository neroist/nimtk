import std/macros

import ./toargs

template configure*(w: typed, args: openArray[(string, string)]) =
  ## Query or modify the configuration options of the widget `w`. 

  w.tk.call($w, "configure", args.toArgs())

template cget*(w: typed, option: string): string =
  ## Returns the current value of the configuration option given by `option`

  w.tk.call($w, "cget", {option: " "}.toArgs())

macro call*(w: typed, args: varargs[string, `$`]) =
  ## Calls command with `w` as the base command, and `args` as the suffix

  result = newCall(
    newDotExpr(newDotExpr(w, ident"tk"), ident"call")
  )

  result.add newCall(ident"$", w)

  for arg in args:
    result.add arg
