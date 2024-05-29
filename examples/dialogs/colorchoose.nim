import std/colors

import nimtk/all

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Color Dialogs"
root.geometry("300x200")

let
  colorButton = root.newButton("color")

colorButton.pack(expand=true)

colorButton.setCommand() do (_: Widget):
  let color = root.chooseColor()

  tk.setPalette(color)

tk.mainloop()
