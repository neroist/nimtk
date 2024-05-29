import std/strutils

import nimtk/ttk
import nimtk/all

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Feet to Meters"

let
  mainframe = root.newTtkFrame()

  feetEntry = mainframe.newTtkEntry("0")
  metersLabel = mainframe.newTtkLabel("0")
  calculateButton = mainframe.newTtkButton("Calculate")

proc calculate(_: Widget) =
  try:
    let value = parseFloat feetEntry.get()

    metersLabel.text = $((0.3048 * value * 10000.0 + 0.5) / 10000.0)
  except ValueError:
    discard

mainframe.grid(0, 0, sticky="nwes")
root.columnconfigure(0, weight=1)
root.rowconfigure(0, weight=1)

feetEntry.grid(2, 1, sticky="we")
metersLabel.grid(2, 2, sticky="we")
calculateButton.grid(3, 3, sticky="w")


newTtkLabel(mainframe, "feet")
  .grid(3, 1, sticky="w")

newTtkLabel(mainframe, "is equivalent to")
  .grid(1, 2, sticky="w")

newTtkLabel(mainframe, "meters")
  .grid(3, 2, sticky="w")

for child in mainframe.children:
  child.grid(padx=5, pady=5)

calculateButton.command = calculate

tk.mainloop()
