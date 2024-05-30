import std/random

import nimtk/all

randomize()

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Choose a Font"

proc applyFont(root: Root, font: Font) =
  for childWidget in root.children:
    childWidget.font = font

let
  choosebutton = root.newButton("Choose")
  randomizebutton = root.newButton("Randomize")

choosebutton.pack(padx=50, pady=50)
randomizebutton.pack(padx=50, pady=50)

choosebutton.setCommand() do (_: Widget):
  tk.fontchooser(
    command = (
      proc (font: Font) = root.applyFont(font)    
    )
  )

  tk.fontchooserShow()

randomizebutton.setCommand() do (_: Widget):
  let font = tk.newFont(family = root.families.sample(), 12)

  root.applyFont(font)

tk.mainloop()
