import ./toargs

template configure*(w: typed, args: openArray[(string, string)]) =
  discard w.tk.call($w, "configure", args.toArgs())

template cget*(w: typed, option: string): string =
  w.tk.call($w, "cget", {option: " "}.toArgs())

template call*(w: typed, args: varargs[string, `$`]) =
  w.tk.call($w, args)
