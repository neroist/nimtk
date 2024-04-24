import std/colors

import ../src/nimtk/widgets
import ../src/nimtk/wm
import ../src/nimtk

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Listbox Example"
root.geometry(width=800, 600)

let
  listbox = root.newListbox(["i", "love", "you"])

listbox.pack()
listbox.selectionSet(0..2)

# the "first=" here is important and allows Nim to properly decide the function to call
# alternatively, call `itemconfigureRange` instead
#
# Example:
# listbox.itemconfigureRange(0, "end", selectbackground=colBlack)
listbox.itemconfigure(first=0, "end", selectbackground=colBlack)
listbox.itemconfigure(1, selectbackground=colHotPink)
echo listbox.get(0..1)

tk.mainloop()
