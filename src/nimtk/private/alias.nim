import std/macros

macro alias*(name: string, fun: untyped) =
  result = newStmtList()

  result.add fun

  result.add newTree(
    fun.kind,      # we are defining a proc

    nnkPostfix.newTree(ident"*", ident(name.strVal)),  # proc name
    newEmptyNode(),  # term rewriting macros stuff
    fun[2],       # generic params
    fun[3],       # formal params
    fun[4],       # pragmas
    newEmptyNode(),  # reserved slot for future use by nim compiler
    fun[^1]       # MEAT
  )

#! syntax highlighting messes up when i use this dsnjfk ughh
macro alias*[LEN](names: array[LEN, string], fun: untyped) =
  result = newStmtList()

  result.add fun

  for name in names:
    result.add newTree(
      fun.kind,      # we are defining a proc

      nnkPostfix.newTree(ident"*", ident(name.strVal)),  # proc name
      newEmptyNode(),  # term rewriting macros stuff
      fun[2],       # generic params
      fun[3],       # formal params
      fun[4],       # pragmas
      newEmptyNode(),  # reserved slot for future use by nim compiler
      fun[^1]       # MEAT
    )
