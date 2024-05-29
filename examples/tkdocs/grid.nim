import nimtk/widgets/ttk/widget
import nimtk/ttk
import nimtk/all

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Grid"

let
  # containers
  content = root.newTtkFrame()
  frame = content.newTtkFrame()

  # state
  oneVar = tk.newTkBool(true)
  twoVar = tk.newTkBool(false)
  threeVar = tk.newTkBool(true)

  # widgets
  nameLabel = content.newTtkLabel("Name")
  nameEntry = content.newTtkEntry()

  oneCheckButton = content.newTtkCheckButton("One")
  twoCheckButton = content.newTtkCheckButton("Two")
  threeCheckButton = content.newTtkCheckButton("Three")
  okButton = content.newTtkButton("Okay")
  cancelButton = content.newTtkButton("Cancel")

# widget configuration
content.padding = [3, 3, 12, 12]

config frame:
  borderwidth = 5
  relief = wrRidge
  width = 200
  height = 100

oneCheckButton.variable = oneVar
twoCheckButton.variable = twoVar
threeCheckButton.variable = threeVar

for chkbtn in [oneCheckButton, twoCheckButton, threeCheckButton]:
  chkbtn.onvalue = true

# widget placement
content.grid(0, 0, sticky="nsew")
frame.grid(0, 0, columnspan=3, rowspan=2, sticky="nsew")
nameLabel.grid(3, 0, columnspan=2, sticky="nw", padx=5)
nameEntry.grid(3, 1, columnspan=2, sticky="new", pady=5, padx=5)
oneCheckButton.grid(0, 3)
twoCheckButton.grid(1, 3)
threeCheckButton.grid(2, 3)
okButton.grid(3, 3)
cancelButton.grid(4, 3)

root.columnconfigure(0, weight=1)
root.rowconfigure(0, weight=1)
content.columnconfigure(0, weight=3)
content.columnconfigure(1, weight=3)
content.columnconfigure(2, weight=3)
content.columnconfigure(3, weight=1)
content.columnconfigure(4, weight=1)
content.rowconfigure(1, weight=1)

tk.mainloop()