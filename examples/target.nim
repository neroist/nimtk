import std/random

import ../src/nimtk/widgets
import ../src/nimtk/images
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
  photo = tk.newPhoto("./target.png").subsample(6) # 1/6 of the size iirc

  button = root.newButton("Click!")

proc placeButton(_: Widget = nil) =
  let root_geo = root.geometry()
  let button_geo = button.geometry()

  button.place(
    rand(0 .. root_geo.width - button_geo.width),
    rand(0 .. root_geo.height - button_geo.height)
  )

  tk.update()

button.image = photo
button.command = placeButton
button.relief = WidgetRelief.Solid
button.borderwidth = 0

placeButton()

tk.mainloop()
