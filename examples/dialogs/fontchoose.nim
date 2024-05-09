import std/random

import ../../src/nimtk/widgets
import ../../src/nimtk/font as _
import ../../src/nimtk/winfo
import ../../src/nimtk/wm
import ../../src/nimtk

randomize()

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Choose a Font"

proc applyFont(root: Root, font: Font) =
  for childWidget in root.children:
    childWidget.font = font

let
  button = root.newButton("Choose")
  button2 = root.newButton("Randomize")

button.pack(padx=50, pady=50)
button2.pack(padx=50, pady=50)

button.setCommand() do (_: Widget):
  root.fontchooser(
    command = (
      proc (font: Font) = root.applyFont(font)    
    )
  )

  root.fontchooserShow()

button2.setCommand() do (_: Widget):
  let font = tk.newFont(family = root.families.sample(), 12)

  root.applyFont(font)

tk.mainloop()
