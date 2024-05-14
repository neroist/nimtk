import std/strformat

import ../src/nimtk/all

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Mouse"
root.geometry(width=800, 600)

let
  label = root.newLabel("Your mouse is at (0, 0)")

label.pack(anchor = AnchorPosition.Center, expand = true, padx = 50, pady = 50)

proc onMouseMove(_: Event) =
  # event.x and event.y may be used instead
  let (x, y) = root.pointerxy()

  label.text = fmt"Your mouse is at ({x}, {y})"

tk.eventAdd("<<Mousemove>>", "<Motion>")
root.bind("<<Mousemove>>", onMouseMove)

tk.mainloop()