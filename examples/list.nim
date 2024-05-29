import std/strutils
import std/colors

import nimtk/all

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Listbox Example"
root.geometry(width=800, 300)

let
  mainframe = root.newFrame()

  listbox = mainframe.newListbox(readFile("list.nim").splitLines())
  scrollbar = mainframe.newScrollbar()

mainframe.grid(0, 0)
root.gridColumnconfigure(0, weight=1)
root.gridRowconfigure(0, weight=1)

listbox.grid(0, 0, sticky = "nesw")
scrollbar.grid(1, 0, sticky = "ns")
mainframe.gridColumnconfigure(0, weight=1)
mainframe.gridRowconfigure(0, weight=1)
mainframe.gridRowconfigure(1, weight=1)

# listbox.selectionSet(0..2)
listbox.selection = 0..2

# set scrollbar
listbox.yscrollbar = scrollbar

# set width to 90 characters
listbox.width = 90

# the "first=" here is important and allows Nim to properly decide the function to call
# alternatively, call `itemconfigureRange` instead
#
# Example:
# listbox.itemconfigureRange(0, "end", selectbackground=colBlack)

listbox.itemconfigure(first=0, "end", selectbackground=colBlack, selectforeground=colWhite)

for idx in countup(0, listbox.len - 1, 2):
  listbox.itemconfigure(idx, selectbackground=colHotPink)

echo listbox.get(0..1)

tk.mainloop()
