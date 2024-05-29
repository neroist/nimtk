## Test file i made when first starting the library

import std/strutils
import std/colors
import std/os

import nimtk/all

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
let 
  frame = root.newFrame()
  msg = frame.newMessage()
  button = frame.newButton("this")
  checkbutton = frame.newCheckButton("meow")
  scale = frame.newScale(1.5..150.0)

# create bool var for checkbutton
let checkvar = tk.newTkBool()

# create image from file
let bitmap = tk.newBitmap(file="./meow.bitmap")

frame.pack(padx = 25, pady = 25)
frame.relief = wrSolid
frame.borderwidth = 2

button.grid(padx = 25, pady = 25) # add button to grid

config button:
  image = bitmap # add image to button
  compound = wcLeft # set image to show left of text
  background = colSpringGreen # set background color
  cursor = curHeart # set cursor
  
  setCommand() do (w: Widget):
    let btn = cast[Button](w)

    btn.flash()
    discard btn.messageBox("alert!", "I love you <3")

checkbutton.grid(padx = 25, pady = 25) # add button2 to grid

config checkbutton:
  variable = checkvar
  background = colSkyBlue # set button2 color
  foreground = colRebeccaPurple
  overrelief = wrRaised
  relief = wrSunken
  cursor = curGobbler # set button2 cursor
  padx = "3c" # set button2 horizontal padding
  
  setCommand() do (w: Widget):
    echo checkvar.get, '\n'

msg.grid(padx = 25, pady = 25)
msg.text = "This is a message! o sitelen a!"
msg.cursor = curGumby

scale.grid(padx = 25, pady = 25)

config scale:
  label = "nanpa!"
  resolution = 0.01
  orient = woHorizontal
  cursor = curExchange

root.selectionHandle("SECONDARY", command=handle)
root.selectionOwn("SECONDARY") do (): echo "lost!"
echo root.selectionGet("SECONDARY")

root.bind("<Button-1>") do (e: Event):
  echo "Clicked widget $1 at ($2, $3)\n" % [$e.widget, $e.x, $e.y]

tk.setPalette({"background": colPink}) # add palette to entire app
tk.mainloop() # run the app
