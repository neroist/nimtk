import std/strutils
import std/macros

# sorry to anyone who wanted to see the source of a proc..,

proc stripComments(fun: NimNode): NimNode =
  ## Strip all doc comments from stmt list `fun`

  result = fun.copy()
  
  var idx: int

  for child in fun.children:
    if child.kind == nnkCommentStmt:
      result.del idx
    
    inc idx

proc addAliasComment(fun: NimNode, originalProc: NimNode): NimNode =
  ## Adds "This is an alias of...` doc comment to stmt list `fun`

  result = newStmtList()

  let procName = 
    if originalProc[0].kind == nnkPostfix:
      $originalProc[0][1]
    else:
      $originalProc[0]

  result.add newCommentStmtNode("This is an alias of `$1`_." % procName)
  result.add fun

macro alias*(name: string, fun: untyped) =
  ## macro to create aliases for routines, so we can do fun stuff!
  ## 
  ## currently just makes an exact copy of the routine but with the aliased name
  
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
    fun[^1].stripComments().addAliasComment(fun)       # MEAT
  )

#! syntax highlighting messes up when i use this dsnjfk ughh
macro alias*[LEN](names: array[LEN, string], fun: untyped) =
  ## Same as above but with multiple aliases

  result = newStmtList()

  result.add fun

  for name in names:
    result.add newTree(
      fun.kind,

      nnkPostfix.newTree(ident"*", ident(name.strVal)),
      newEmptyNode(),
      fun[2],
      fun[3],
      fun[4],
      newEmptyNode(),
      fun[^1].stripComments().addAliasComment(fun) 
    )
