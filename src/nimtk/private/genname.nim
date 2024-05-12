import std/oids

proc genName*(): string =
  $genOid()

proc genName*(start: string): string =
  start & $genOid()
