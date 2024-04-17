import std/colors

import ../src/nimtk/widgets
import ../src/nimtk

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

button2.grid(padx = (100.0, 100.0), pady = (100.0, 100.0)) # add button2 to grid
button2.background = colSkyBlue # set button2 color
button2.cursor = Middlebutton # set button2 cursor
button2.padx = "3c" # set button2 horizontal padding

msg.grid(padx = (50.0, 50.0), pady = (50.0, 50.0))
msg.text = "This is a message! o sitelen a!"
msg.cursor = Star

tk.setPalette({"background": colHotPink}) # add palette to entire app
tk.mainloop() # run the app
