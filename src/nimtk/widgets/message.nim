import std/strutils

import ../utils/escaping
import ../utils/genname
import ../../nimtk
import ./widget

type
  Message* = ref object of Widget

proc isMessage*(w: Widget): bool = "message" in w.pathname.split('.')[^1]

proc newMessage*(parent: Widget, text: string = ""): Message =
  new result

  result.pathname = pathname(parent.pathname, genName("message_"))
  result.tk = parent.tk

  discard result.tk.call("message", result.pathname)

  if text.len > 0:
    result.configure({"text": tclEscape text})

proc `aspect=`*(m: Message, aspect: int) = m.configure({"aspect": $aspect})

proc aspect*(m: Message): int = parseInt m.cget("aspect")
