import std/strutils

import ./widget
import ../../nimtk

type
  Message* = ref object of Widget

proc newMessage*(parent: Widget): Message =
  new result

  result.pathname = pathname(parent.pathname, genName("message_"))
  result.tk = parent.tk

  discard result.tk.call("message", result.pathname)

proc `aspect=`*(m: Message, aspect: int) = m.configure({"aspect": $aspect})

proc aspect*(m: Message): int = parseInt m.cget("aspect")
