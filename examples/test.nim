import std/colors
import std/os

import ../src/nimtk/widgets
import ../src/nimtk/images
import ../src/nimtk/wm
import ../src/nimtk

# lets set the cwd to the app dir
setCurrentDir(getAppDir())

let foo = "This is a string with some data in it... blah blah"

proc handle*(offset, maxChars: int, _: pointer): string =
  echo "offset: ", offset
  echo "maxChars: ", maxChars

  return foo[offset.clamp(0, foo.len) .. (offset+maxChars).clamp(offset, foo.len) - 1]

let tk = newTk() # create tck & tk interpreter
let root = tk.getRoot() # get main (root) window

root.title = "test.nim"
root.resizable = false

# create two buttons
let frame = root.newFrame()
let msg = frame.newMessage()
let button = frame.newButton("this")
let button2 = frame.newButton("meow")

# create image from file
let bitmap = tk.newBitmap(file="./meow.bitmap")

frame.pack(padx = 25, pady = 25)
frame.relief = Solid
frame.borderwidth = 2

button.grid(padx = (100.0, 100.0), pady = (100.0, 100.0)) # add button to grid
button.bitmap = bitmap # add image to button
button.compound = WidgetCompound.Left # set image to show left of text
button.background = colSpringGreen # set background color
button.cursor = Heart # set cursor
button.setCommand(clientdata=nil) do (_: Widget, _: pointer): echo "i love you"

button2.grid(padx = (100.0, 100.0), pady = (100.0, 100.0)) # add button2 to grid
button2.background = colSkyBlue # set button2 color
button2.cursor = Middlebutton # set button2 cursor
button2.padx = "3c" # set button2 horizontal padding

msg.grid(padx = (50.0, 50.0), pady = (50.0, 50.0))
msg.text = "This is a message! o sitelen a!"
msg.cursor = Star

root.selectionHandle("SECONDARY", command=handle)
root.selectionOwn("SECONDARY", nil) do (_: pointer): echo "lost!"
echo root.selectionGet("SECONDARY")

root.bind("<Button-1>", nil) do (e: Event, _: pointer): echo e.widget

tk.setPalette({"background": colHotPink}) # add palette to entire app
tk.mainloop() # run the app
