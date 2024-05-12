import std/strutils
import std/random

import ../src/nimtk/widgets
import ../src/nimtk/wm
import ../src/nimtk

randomize()

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Random Number Generator"
root.resizable = false

let
  frame = root.newFrame()

  beginVar = tk.newTkString("0")
  endVar = tk.newTkString("0")

  beginLabel = frame.newLabel("Starting number:")
  beginEntry = frame.newEntry()

  endLabel = frame.newLabel("Ending number:")
  endEntry = frame.newEntry()

  numberLabel = frame.newLabel()
  
  genButton = frame.newButton("Generate!")

frame.pack(fill=FillStyle.Both, expand=true, padx=20, pady=20)

# intended ui:
# 
#     0          1          2
# beginLabel             endLabel   0
# beginEntry             endEntry   1
#            numberLabel            2
#            genButton              3

beginLabel.grid(column=0, row=0)
beginEntry.grid(column=0, row=1)

endLabel.grid(column=2, row=0)
endEntry.grid(column=2, row=1)

numberLabel.grid(column=1, row=3)

genButton.grid(column=1, row=4)

beginEntry.textvariable = beginVar
endEntry.textvariable = endVar

proc validate(_: Widget, event: EntryEvent): bool =
  try:
    discard parseInt(event.editedValue)
  except ValueError:
    return false

  return true

proc invalid(w: Widget, _: EntryEvent): bool =
  w.bell()

beginEntry.validatecommand = validate
endEntry.validatecommand = validate

beginEntry.invalidcommand = invalid
endEntry.invalidcommand = invalid

genButton.setCommand() do (w: Widget):
  if not (beginEntry.validate() and endEntry.validate()):
    return

  let (num1, num2) = (parseInt beginVar, parseInt endVar)

  if num1 > num2:
    w.bell()
    return

  numberLabel.text = $rand num1..num2

tk.mainloop()
