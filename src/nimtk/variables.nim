import std/strutils
import std/oids

import ../nimtk

type
  TkString* = ref object of RootObj
    varname*: string
    tk*: Tk

  TkFloat* = ref object of RootObj
    varname*: string
    tk*: Tk

  TkBool* = ref object of RootObj
    varname*: string
    tk*: Tk
  
  TkVar* = TkString or TkFloat or TkBool

proc `$`*(`var`: TkVar): string

proc genName*(): string =
  $genOid()

proc genName*(start: string): string =
  start & $genOid()

template newTkVarImpl(tk: Tk, val1: float or bool or string) {.dirty.} =
  new result

  result.varname = genName()
  result.tk = tk

  discard tk.call("set", result.varname, $val1)

proc newTkString*(tk: Tk, val: string = ""): TkString = newTkVarImpl(tk, (repr val))
proc newTkFloat*(tk: Tk, val: float = 0): TkFloat = newTkVarImpl(tk, val)
proc newTkBool*(tk: Tk, val: bool = false): TkBool = newTkVarImpl(tk, val)

proc get*(`var`: TkString): string =
  if `var`.tk == nil: return

  `var`.tk.call("set", `var`.varname)
  `var`.tk.result

proc get*(`var`: TkFloat): float =
  if `var`.tk == nil: return

  `var`.tk.call("set", `var`.varname)
  `var`.tk.result.parseFloat()

proc get*(`var`: TkBool): bool =
  if `var`.tk == nil: return

  `var`.tk.call("set", `var`.varname)
  `var`.tk.result.parseBool()

proc set*(`var`: TkVar, val: string | float | bool) =
  if `var`.tk == nil: return

  `var`.tk.call("set", `var`.varname, $val)

proc `$`*(`var`: TkVar): string =
  if `var` == nil or `var`.tk == nil: ""
  else: $`var`.get()

converter tkStringToStr*(`var`: TkString): string = `var`.get()
converter tkFloatToFloat*(`var`: TkFloat): float = `var`.get()
converter tkBoolToBool*(`var`: TkBool): bool = `var`.get()
