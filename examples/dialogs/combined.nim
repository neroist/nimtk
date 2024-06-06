import std/strformat
import std/random
import std/colors
import std/os

import nimtk/ttk
import nimtk/all

randomize()

let
  tk = newTk()
  root = tk.getRoot()

root.title = "NimTk Dialogs"
root.geometry("450x300")

let
  notebook = root.newNotebook()

  colorFrame = notebook.newTtkFrame()
  fileFrame = notebook.newTtkFrame()
  fontFrame = notebook.newTtkFrame()

  # colorFrame
  colorButton = colorFrame.newTtkButton("Color Button")

  # fileFrame
  openButton = fileFrame.newTtkButton("Open File")
  saveButton = fileFrame.newTtkButton("Save File")
  dirButton = fileFrame.newTtkButton("Choose Directory")

  # fontFrame
  choosebutton = fontFrame.newTtkButton("Choose")
  randomizebutton = fontFrame.newTtkButton("Randomize")

# grid notebook & mainframe
root.columnconfigure(0, weight=1)
root.rowconfigure(0, weight=1)
notebook.grid(0, 0, sticky="nsew", padx=10, pady=10)

# --- add colorFrame
notebook.add colorFrame, "Color Dialog"

colorButton.pack(expand=true)
colorButton.setCommand() do (_: Widget):
  let color = root.chooseColor()

  # not the best but an empty string may be returned here by tk
  # as such we need to handle it
  if color.len == 0:
    return

  tk.setPalette(parseColor color)


# --- add fileFrame
notebook.add fileFrame, "File & Directory Dialogs"

openButton.pack(expand=true)
saveButton.pack(expand=true)
dirButton.pack(expand=true)

openButton.setCommand() do (_: Widget):
  let files = root.getOpenFile(
    title = "Open a file",
    filetypes = @[
      ("Nim Source Files", @[".nimf", ".nim", ".nims", ".nimble"]),
      ("Stylesheets", @[".css", ".less", ".sass", ".scss", ".bass"]),
      ("Any File", @["*"])
    ],
    initialfile = currentSourcePath(),
    initialdir = currentSourcePath().parentDir(),
    multiple = true
  )

  if files.len < 1:
    return

  discard root.messageBox(
    title = "You opened a file!",
    message = "You opened " & files[0].splitPath().tail,
    detail = "Directory: " & files[0].parentDir().splitPath().tail
  )

saveButton.setCommand() do (_: Widget):
  let file = root.getSaveFile(
    title = "Open a file",
    filetypes = @[
      ("C/C++ Source Files", @[".c", ".cc", ".h", ".hh", ".cpp", ".hpp"]),
      ("Any File", @["*"])
    ],
    initialfile = currentSourcePath(),
    initialdir = currentSourcePath().parentDir(),
    confirmoverwrite = true
  )

  if file.len < 1:
    return

  discard root.messageBox(
    title = "You saved a file!",
    message = "You opened " & file.splitPath().tail,
    detail = "Directory: " & file.parentDir().splitPath().tail
  )

dirButton.setCommand() do (_: Widget):
  let dir = root.chooseDirectory(
    title = "Open a file",
    initialdir = currentSourcePath().parentDir(),
    mustexist = true
  )

  if dir.len < 1:
    return

  discard root.messageBox(
    title = "You chose a directory!",
    message = "Directory: " & dir.parentDir().splitPath().tail
  )

# --- add fontFrame
notebook.add fontFrame, "Choose-a-font"

# since ttk widgets dont support the `font` option,
# we need to do something different
proc applyFont(root: Root, font: Font) =
  discard root.messageBox(
    title = "You chose a font!",
    message = &"You chose the font \"{font.family}\"!"
  )

choosebutton.pack(expand=true)
randomizebutton.pack(expand=true)

choosebutton.setCommand() do (_: Widget):
  tk.fontchooser(
    command = (proc (font: Font) = root.applyFont(font))
  )

  tk.fontchooserShow()

randomizebutton.setCommand() do (_: Widget):
  let font = tk.newFont(family = root.families.sample(), 12)

  root.applyFont(font)

tk.mainloop()
