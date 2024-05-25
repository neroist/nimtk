import std/strutils

import nimtk/ttk
import nimtk/all

let
  tk = newTk()
  root = tk.getRoot()

let
  val = tk.newTkFloat()

  mainframe = root.newTtkFrame()

  progressbar = mainframe.newProgressBar()
  valueLabel = mainframe.newTtkLabel("The progress bar's current value is 0/" & $ int progressbar.maximum)
  startButton = mainframe.newTtkButton("Start")
  stepButton = mainframe.newTtkButton("Step")
  stopButton = mainframe.newTtkButton("Stop")
  resetButton = mainframe.newTtkButton("Reset")

config progressbar:
  orient = WidgetOrientation.Horizontal
  length = 300
  variable = val

mainframe.grid(0, 0)
root.gridRowConfigure(0, weight=1)
root.gridColumnConfigure(0, weight=1)

progressbar.grid(0, 0, columnspan=4, padx=20, pady=20)
valueLabel.grid(0, 1)
startButton.grid(0, 2, sticky="w")
stepButton.grid(1, 2, sticky="w")
stopButton.grid(2, 2, sticky="e")
resetButton.grid(3, 2, sticky="e")

mainframe.gridRowConfigure(0..2, weight=1)
mainframe.gridColumnConfigure(0..1, weight=1)

# trace var to update label
val.trace([toWrite, toRead]) do:
  # val.get doesnt work..,, idk why
  valueLabel.text = "The progress bar's current value is $1/$2" % [$ int progressbar.value, $ int progressbar.maximum]

# button callbacks
startButton.setCommand() do (_: Widget):
  start progressbar

stepButton.setCommand() do (_: Widget):
  inc val

stopButton.setCommand() do (_: Widget):
  # get and set to maintain current progress bar value
  # `stop` seems to reset the value
  let currval = val.get()
  
  stop progressbar
  val.set currval

resetButton.setCommand() do (_: Widget):
  val.set 0

# odd but needed to display the proper value
stop progressbar

tk.mainloop()
