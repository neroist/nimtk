import std/strutils

import ../../src/nimtk/widgets
import ../../src/nimtk/wm
import ../../src/nimtk

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Counter"

let
  counterEntry = root.newEntry("0")
  counterButton = root.newButton("Counter")

counterEntry.grid(0, 0, padx=5, pady=5)
counterButton.grid(1, 0, padx=5, pady=5)

counterButton.setCommand(nil) do (_: Widget, _: pointer):
  let currentCount = parseInt counterEntry.get()

  counterEntry.set $(currentCount + 1)

tk.mainloop()