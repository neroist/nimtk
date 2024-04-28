import std/strutils

import ../../src/nimtk/widgets
import ../../src/nimtk/tcl
import ../../src/nimtk/wm
import ../../src/nimtk

let
  tk = newTk()
  root = tk.getRoot()

root.title = "CRUD (Create, Read, Update, Destroy)"

let
  mainframe = root.newFrame()

  filterPrefixLabel = mainframe.newLabel("Filter prefix:")
  filterPrefixEntry = mainframe.newEntry()

  namesListbox = mainframe.newListbox(["Emil, Hans", "Mustermann, Maxx", "Tisch, Roman"])

  nameLabel = mainframe.newLabel("Name:")
  nameEntry = mainframe.newEntry()
  surnameLabel = mainframe.newLabel("Surname:")
  surnameEntry = mainframe.newEntry()

  createButton = mainframe.newButton("Create")
  updateButton = mainframe.newButton("Update")
  deleteButton = mainframe.newButton("Delete")

mainframe.pack(expand=true, padx=32, pady=24)

filterPrefixLabel.grid(0, 0, pady=15)
filterPrefixEntry.grid(1, 0)

namesListbox.grid(0, 1, columnspan=2, rowspan=2, sticky=AnchorPosition.West, padx=(15, 0))
namesListbox.selectMode = SelectMode.Single

nameLabel.grid(2, 1, padx=0)
nameEntry.grid(3, 1)

surnameLabel.grid(2, 2)
surnameEntry.grid(3, 2)

createButton.grid(0, 3, pady=15)
updateButton.grid(1, 3)
deleteButton.grid(2, 3)

namesListbox.bind("<<ListboxSelect>>") do (_: Event):
  let selection = namesListbox.selection

  if selection.len != 0:
    let nameSeq = selection[0].split(", ")
    let (name, surname) = (nameSeq[0], nameSeq[1])

    nameEntry.set name
    surnameEntry.set surname
  else:
    nameEntry.clear()
    surnameEntry.clear()

surnameEntry.bi

tk.mainloop()
