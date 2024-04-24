import std/strutils

proc toArgs*(map: openArray[tuple[name, val: string]]): string =
  for tup in map:
    if tup.val.len == 0: continue

    result.add "-" & tup.name & " " & tup.val.strip() & " "

