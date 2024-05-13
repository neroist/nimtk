import slappy

import ../src/nimtk/all

const
  padx = 4
  pady = 4

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Password Generator"
root.resizable = false

let
  menuBar = root.newMenu()
  windowMenu = menuBar.newMenu()
  presetsMenu = menuBar.newMenu()

  mainframe = root.newFrame()
