import std/colors

import nimtk/all

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Color Dialog"
root.geometry("300x200")

let
  colorButton = root.newButton("color")

colorButton.pack(expand=true)

colorButton.setCommand() do (_: Widget):
  let color = root.chooseColor()

  # not the best but an empty string may be returned here by tk
  # as such we need to handle it
  if color.len == 0:
    return

  tk.setPalette(parseColor color)

tk.mainloop()
