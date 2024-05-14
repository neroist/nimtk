import std/colors

import nimtk/all

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Color Dialogs"

let
  colorButton = root.newButton("color")

colorButton.pack(padx=50, pady=50)

colorButton.setCommand() do (_: Widget):
  let color = root.chooseColor()
  tk.setPalette(color)

tk.mainloop()
