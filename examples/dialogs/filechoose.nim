import std/os

import ../../src/nimtk/widgets
import ../../src/nimtk/winfo
import ../../src/nimtk/wm
import ../../src/nimtk

let
  tk = newTk()
  root = tk.getRoot()

root.title = "File & Directory Dialogs"

let
  openButton = root.newButton("Open File")
  saveButton = root.newButton("Save File")
  dirButton = root.newButton("Choose Directory")

openButton.pack(padx=30, pady=50)
saveButton.pack(padx=30, pady=50)
dirButton.pack(padx=30, pady=50)

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

  # when using `initialfile` the initial file will
  # always be the first element (unless the dialog)
  # was closed
  if files.len < 2:
    return

  discard root.messageBox(
    title = "You opened a file!",
    message = "You opened " & files[1].splitPath().tail,
    detail = "Directory: " & files[1].parentDir().splitPath().tail
  )

saveButton.setCommand() do (_: Widget):
  let file = root.getSaveFile(
    title = "Open a file",
    defaultextension = "1",
    filetypes = @[
      ("C/C++ Source Files", @[".c", ".cc", ".h", ".hh", ".cpp", ".hpp"]),
      ("Any File", @["*"])
    ],
    initialfile = currentSourcePath(),
    initialdir = currentSourcePath().parentDir(),
    confirmoverwrite = true
  )

  discard root.messageBox(
    title = "You saved a file!",
    message = "You opened " & file.splitPath().tail,
    detail = "Directory: " & file.parentDir().splitPath().tail
  )

dirButton.setCommand() do (_: Widget):
  let file = root.chooseDirectory(
    title = "Open a file",
    initialdir = currentSourcePath().parentDir(),
    mustexist = true
  )

  discard root.messageBox(
    title = "You chose a directory!",
    message = "Directory: " & file.parentDir().splitPath().tail
  )

tk.mainloop()
