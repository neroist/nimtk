import std/random

import nimtk/all

randomize()

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Click!"
root.geometry(width=800, 600)

let
  photo = tk.newPhoto("./assets/target.png").subsample(6) # 1/6 of the size

  button = root.newButton()

proc placeButton(_: Widget = nil) =
  let root_geo = root.geometry()
  let button_geo = button.geometry()

  button.place(
    rand(0 .. root_geo.width - button_geo.width),
    rand(0 .. root_geo.height - button_geo.height)
  )

  tk.update()

config button:
  image = photo
  command = placeButton
  relief = wrSolid
  borderwidth = 0

placeButton()

tk.mainloop()
