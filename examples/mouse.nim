import std/strformat

import ../src/nimtk/widgets
import ../src/nimtk/winfo
import ../src/nimtk/wm
import ../src/nimtk

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Mouse"
root.geometry(width=800, 600)

let
  entry = root.newEntry()

entry.pack(anchor = AnchorPosition.Center, expand = true, padx = 50, pady = 50)

proc onMouseMove(_: Event) =
  # event.x and event.y may be used instead
  let (x, y) = root.pointerxy()

  entry.set(fmt"Your mouse is at ({x}, {y})")

tk.eventAdd("<<Mousemove>>", "<Motion>")
root.bind("<<Mousemove>>", onMouseMove)

tk.mainloop()