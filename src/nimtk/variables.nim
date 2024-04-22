import std/strutils
import std/oids

import ./private/escaping
import ../nimtk

type
  TkVar* = ref object of RootObj
    varname*: string
    tk*: Tk

  TkString* = ref object of TkVar
  TkFloat* = ref object of TkVar
  TkInt* = ref object of TkVar
  TkBool* = ref object of TkVar

<<<<<<< HEAD
  TkVarType* = TkString or TkFloat or TkInt or TkBool
=======
  TkVarType* = TkString or TkFloat or TkBool
  
proc `$`*(`var`: TkVar): string
>>>>>>> 2b988a3fa2b85ad5c8baf98a9e89e8628697b9b4

proc genName*(): string =
  $genOid()

proc genName*(start: string): string =
  start & $genOid()

template createTkVar*(tk1: Tk, name: string) {.dirty.} =
  if name.len == 0:
    return nil

  new result

  result.varname = name
  result.tk = tk1

template newTkVarImpl(tk: Tk, val1: typed) {.dirty.} =
  new result

  when val1 is float:
    result.varname = genName("float_")
  elif val1 is int:
    result.varname = genName("int_")
  elif val1 is bool:
    result.varname = genName("bool_")
  else:
    result.varname = genName("string_")
    
  result.tk = tk

  discard tk.call("set", result.varname, $val1)

template getImpl(v: TkVar, endproc: proc) =
  if v.tk.isNil(): return

  v.tk.call("set", v.varname)
  return v.tk.result.endproc

template tkString*(v: TkVar): TkString = cast[TkString](v)
template tkFloat*(v: TkVar): TkFloat = cast[TkFloat](v)
template tkInt*(v: TkVar): TkInt = cast[TkInt](v)
template tkBool*(v: TkVar): TkBool = cast[TkBool](v)

proc newTkString*(tk: Tk, val: string = ""): TkString = newTkVarImpl(tk, (tclEscape val))
proc newTkFloat*(tk: Tk, val: float = 0): TkFloat = newTkVarImpl(tk, val)
proc newTkBool*(tk: Tk, val: bool = false): TkBool = newTkVarImpl(tk, val)
proc newTkInt*(tk: Tk, val: int = 0): TkInt = newTkVarImpl(tk, val)

proc get*(`var`: TkString or TkVar): string =
  getImpl(`var`, `$`) # errors should not be possible here

proc get*(`var`: TkFloat): float =
  try:
    getImpl(`var`, parseFloat)
  except ValueError:
    raise newException(TkError, "Error when parsing TkFloat as a float: $1 cannot be parsed as a float" % tclEscape $cast[TkString](`var`))

proc get*(`var`: TkBool): bool =
  try:
    getImpl(`var`, parseBool)
  except ValueError:
    raise newException(TkError, "Error when parsing TkBool as a bool: $1 cannot be parsed as a bool" % $cast[TkString](`var`))

proc set*(`var`: TkVar, val: string | float | bool | int) =
  if `var`.tk == nil: return

  when val is string:
    `var`.tk.call("set", `var`.varname, tclEscape val)
  else:
    `var`.tk.call("set", `var`.varname, $val)

proc add*(`var`: TkString, val: string) =
  `var`.set(`var`.get() & val)

proc `$`*(`var`: TkVar): string =
  if `var` == nil or `var`.tk == nil: ""
  else: $`var`.get()

converter tkStringToStr*(`var`: TkString): string = `var`.get()
converter tkFloatToFloat*(`var`: TkFloat): float = `var`.get()
converter tkBoolToBool*(`var`: TkBool): bool = `var`.get()
converter tkIntToInt*(`var`: TkInt): int = `var`.get()
