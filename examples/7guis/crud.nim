import std/strutils

import nimtk/all

var names = @[
  "Emil, Hans",
  "Mustermann, Maxx",
  "Tisch, Roman",

  "Aden, Butler",
  "Perla, Holmes",
  "Tripp, Lozano",
  "Britney, Adams",
  "Jamie, Moore",
  "Alma, Mccoy",
  "Amelia, Hickman",
  "Terrence, Salas",
  "Haiden, Copeland",
  "Milo, Gillespie",
  "Marlee, Haas",
  "Jett, Brock"
]

let
  tk = newTk()
  root = tk.getRoot()

root.title = "CRUD (Create, Read, Update, Destroy)"

let
  mainframe = root.newFrame()

  filterPrefixLabel = mainframe.newLabel("Filter prefix:") # TODO
  filterPrefixEntry = mainframe.newEntry()

  namesFrame = mainframe.newFrame()
  namesListbox = namesFrame.newListbox(names)
  namesScrollbar = namesFrame.newScrollbar()

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

# -- namesframe
namesFrame.grid(0, 1, columnspan=2, rowspan=2, sticky=AnchorPosition.West, padx=(15, 0))

namesListbox.pack(side=Side.Left)
namesScrollbar.pack(side=Side.Right, fill=FillStyle.Y)
# !--

nameLabel.grid(2, 1, padx=0)
nameEntry.grid(3, 1)

surnameLabel.grid(2, 2)
surnameEntry.grid(3, 2)

createButton.grid(0, 3, pady=15)
updateButton.grid(1, 3)
deleteButton.grid(2, 3)

# widget configuration
namesListbox.relief = WidgetRelief.Flat
namesListbox.yscrollbar = namesScrollbar
namesListbox.selectMode = SelectMode.Single

for child in mainframe.children:
  if (not child.isLabel):
    child.relief = WidgetRelief.Solid
    child.borderwidth = 1

# functionality

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

# TODO...
# filterPrefixEntry.bind("<Key>") do (_: Event):

updateButton.setCommand() do (_: Widget):
  let selection = namesListbox.curselection

  if selection.len != 0:
    let (name, surname) = (nameEntry.get(), surnameEntry.get())
    let index = selection[0]

    # deleting and creating a new item in the listbox
    # so it seems like we're really updating it
    namesListbox.delete index
    namesListbox[index] = [name, surname].join(", ")

deleteButton.setCommand() do (_: Widget):
  let selection = namesListbox.curselection

  if selection.len != 0:
    let index = selection[0]

    namesListbox.delete index

    nameEntry.clear()
    surnameEntry.clear()

createButton.setCommand() do (_: Widget):
  let (name, surname) = (nameEntry.get(), surnameEntry.get())

  if not (name.isEmptyOrWhitespace() or surname.isEmptyOrWhitespace()):
    namesListbox.add [name, surname].join(", ")

tk.mainloop()
