import std/colors

import ../src/nimtk/widgets
import ../src/nimtk/wm
import ../src/nimtk

let
  tk = newTk()
  root = tk.getRoot()

root.geometry(width = 800, 600)

proc onRadioClick(radio: Widget, _: pointer) =
  let radio = cast[RadioButton](radio)
  echo radio.value

let
  mainframe = root.newFrame()

  frame1 = mainframe.newLabelFrame("Question 1")
  frame2 = mainframe.newLabelFrame("Question 2")
  frame3 = mainframe.newLabelFrame("Question 3")
  frame4 = mainframe.newLabelFrame("Question 4")

mainframe.relief = Solid
mainframe.background = colRebeccaPurple

mainframe.pack(ipadx = 50, ipady = 50, expand = true)

for idx, frame in [frame1, frame2, frame3, frame4]:
  frame.grid(padx = 25, pady = 25, ipadx = 50, ipady = 50, column = (idx + 1) mod 2, row = int(idx > 1))
  frame.relief = Solid
  frame.cursor = Heart

  for i in 1..4:
    let radio = frame.newRadioButton("Button " & $i)
    radio.command = onRadioClick
    radio.deselect()
    radio.pack()

tk.mainloop()
