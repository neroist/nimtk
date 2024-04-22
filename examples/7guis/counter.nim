import std/strutils

import ../../src/nimtk/widgets/entry
import ../../src/nimtk/widgets
import ../../src/nimtk/wm
import ../../src/nimtk

let
  tk = newTK()
  root = tk.getRoot()

let
  counterVar = tk.newTkString("0")

  counterEntry = root.newEntry()
  counterButton = root.newButton("Counter")

counterEntry.grid(0, 0)
counterButton.grid(1, 0)

counterEntry.textvariable = counterVar
# counterEntry.readonly = true

counterButton.setCommand(nil) do (_: Widget, _: pointer):
  counterVar.set $(parseInt(counterVar.get()) + 1)

tk.mainloop()