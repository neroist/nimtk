import std/strutils
import std/colors
import std/os

import ../src/nimtk/widgets
import ../src/nimtk/images
import ../src/nimtk/wm
import ../src/nimtk

# lets set the cwd to the app dir
setCurrentDir(getAppDir())

let foo = "This is a string with some data in it... blah blah\n"

proc handle*(offset, maxChars: int): string =
  echo "offset: ", offset
  echo "maxChars: ", maxChars

  return foo[offset.clamp(0, foo.len) .. (offset+maxChars).clamp(offset, foo.len) - 1]

let tk = newTk() # create tck & tk interpreter
let root = tk.getRoot() # get main (root) window

root.title = "test.nim"
# root.resizable = false
root.maxsize = (800, 800)

# create two buttons
let frame = root.newFrame()
let msg = frame.newMessage()
let button = frame.newButton("this")
let checkbutton = frame.newCheckButton("meow")
let scale = frame.newScale(1.5..150.0)

# create bool var for checkbutton
let checkvar = tk.newTkBool()

# create image from file
let bitmap = tk.newBitmap(file="./meow.bitmap")

frame.pack(padx = 25, pady = 25)
frame.relief = Solid
frame.borderwidth = 2

button.grid(padx = 25, pady = 25) # add button to grid
button.bitmap = bitmap # add image to button
button.compound = WidgetCompound.Left # set image to show left of text
button.background = colSpringGreen # set background color
button.cursor = Heart # set cursor
button.setCommand() do (w: Widget):
  let btn = cast[Button](w)

  btn.flash()
  btn.messageBox("alert!", "I love you <3")

checkbutton.grid(padx = 25, pady = 25) # add button2 to grid
checkbutton.variable = checkvar
checkbutton.background = colSkyBlue # set button2 color
checkbutton.foreground = colRebeccaPurple
checkbutton.overrelief = WidgetRelief.Raised
checkbutton.relief = WidgetRelief.Sunken
checkbutton.cursor = Gobbler # set button2 cursor
checkbutton.padx = "3c" # set button2 horizontal padding
checkbutton.setCommand() do (w: Widget):
  echo checkvar.get, '\n'

msg.grid(padx = 25, pady = 25)
msg.text = "This is a message! o sitelen a!"
msg.cursor = Gumby

scale.grid(padx = 25, pady = 25)
scale.label = "nanpa!"
scale.resolution = 0.01
scale.orient = Horizontal
scale.cursor = Exchange

root.selectionHandle("SECONDARY", command=handle)
root.selectionOwn("SECONDARY") do (): echo "lost!"
echo root.selectionGet("SECONDARY")

root.bind("<Button-1>") do (e: Event):
  echo "Clicked widget $1 at ($2, $3)\n" % [$e.widget, $e.x, $e.y]

tk.setPalette({"background": colPink}) # add palette to entire app
tk.mainloop() # run the app
