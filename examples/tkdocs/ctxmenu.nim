import ../src/nimtk/widgets
import ../src/nimtk/wm
import ../src/nimtk

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Context Menus Example"
root.geometry(width=800, 600)

let
  menu = root.newMenu()

proc popupMenu(event: Event) =
  # popup the menu
  # use popup *not* post!
  menu.popup(event.xRoot, event.yRoot)

# we dont want our context menu to tear off into a different window
menu.tearoff = false

# add commands
for i in ["One", "Two", "Three"]:
  menu.addCommand(i)

# special stuff for MacOS' windowing system
if tk.windowingsystem == "aqua":
  root.bind("<2>", popupMenu)
  root.bind("<Control-1>", popupMenu)
else:
  root.bind("<3>", popupMenu)

tk.mainloop()
