import std/random

import ../src/nimtk/widgets
import ../src/nimtk/winfo
import ../src/nimtk/tcl
import ../src/nimtk/wm
import ../src/nimtk

randomize()

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Click!"
root.geometry(width=800, 600)

let
  button = root.newButton("Click!")

proc placeButton(_: Widget = nil) =
  tk.update()

  let root_geo = root.geometry()
  let button_geo = button.geometry()

  button.place(
    rand(0 .. root_geo.width - button_geo.width),
    rand(0 .. root_geo.height - button_geo.height)
  )

button.command = placeButton

button.height = 5
button.width = 10
button.relief = WidgetRelief.Solid

placeButton()

tk.mainloop()
