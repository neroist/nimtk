import std/strformat

import nimtk/ttk
import nimtk/all

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Scrolling"

let
  listbox = root.newListbox()
  scrollbar = root.newTtkScrollbar()
  label = root.newTtkLabel("Status message here")

# widget configuration
listbox.height = 5
listbox.yscrollbar = scrollbar
label.anchor = apWest

# widget placement
listbox.grid(0, 0, sticky="nwes")
scrollbar.grid(1, 0, sticky="ns")
label.grid(0, 1, columnspan=2, sticky="we")

root.columnConfigure(0, weight=1)
root.rowConfigure(0, weight=1)

for i in 1..100:
  listbox.add fmt"Line {i} of 100"

tk.mainloop()
