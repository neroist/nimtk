from std/strutils import strip

proc toArgs*(map: openArray[tuple[name, val: string]]): string =
  ## Convert "table" `map` to Tcl-style `-option value` args
  ##
  ## `{"this": "that"}` -> `-this that`
  
  for tup in map:
    if tup.val.len == 0: continue

    result.add "-" & tup.name & " " & tup.val.strip() & " "
