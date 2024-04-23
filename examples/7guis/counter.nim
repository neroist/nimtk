import std/strutils

import ../../src/nimtk/widgets/entry
import ../../src/nimtk/widgets
import ../../src/nimtk/wm
import ../../src/nimtk

let
  tk = newTK()
  root = tk.getRoot()

let
  counterEntry = root.newEntry("0")
  counterButton = root.newButton("Counter")

counterEntry.grid(0, 0)
counterButton.grid(1, 0)

counterEntry.set "0"

# counterEntry.textvariable = counterVar
# counterEntry.readonly = true

counterButton.setCommand(nil) do (_: Widget, _: pointer):
  let currentCount = parseInt counterEntry.get()

  counterEntry.set $(currentCount + 1)

tk.mainloop()