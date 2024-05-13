import std/oids

proc genName*(): string {.inline.} =
  ## Generates a random & unique identifier with oids (https://nim-lang.org/docs/oids.html).

  $genOid()

proc genName*(start: string): string {.inline.} =
  ## Create an identifier with `start` at the start.
  ##
  ## This is used to create widget pathnames & tcl variable names and such.

  start & $genOid()
