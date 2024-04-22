import std/strformat

import ../src/nimtk/widgets
import ../src/nimtk/winfo
import ../src/nimtk/wm
import ../src/nimtk

let
  tk = newTk()
  root = tk.getRoot()

root.geometry(width=800, 600)

let
  textvar = tk.newTkString("Your mouse is at (0, 0)")
  label = root.newEntry()

label.pack(anchor = AnchorPosition.Center, expand = true, padx = 50, pady = 50)
label.textvariable = textvar

proc onMouseMove(_: Event, _: pointer) =
  # event.x and event.y may be used instead
  let (x, y) = root.pointerxy()

  textvar.set(fmt"Your mouse is at ({x}, {y})")

tk.eventAdd("<<Mousemove>>", "<Motion>")
root.bind("<<Mousemove>>", nil, onMouseMove)

tk.mainloop()