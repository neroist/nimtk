import std/strutils
import std/random

import ../src/nimtk/all

randomize()

const
  padx = 4
  pady = 4

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Password Generator"
root.resizable = false

let
  menuBar = root.newMenu()
  windowMenu = menuBar.newMenu()
  presetsMenu = menuBar.newMenu()

  mainframe = root.newFrame()

  lenLabel = mainframe.newLabel("How many characters should be in the password?")
  lenEntry = mainframe.newEntry($rand(16..32))

  passwordLabel = mainframe.newLabel("Password:")
  passwordEntry = mainframe.newEntry()

  generateButton = mainframe.newButton("Generate!")

  uppercharsCheckbutton = mainframe.newCheckbutton("Uppercase characters (A-Z)")
  lowercharsCheckbutton = mainframe.newCheckbutton("Lowercase characters (A-Z)")
  digitsCheckbutton = mainframe.newCheckbutton("Digits (0-9)")
  specialcharsCheckbutton = mainframe.newCheckbutton("Special characters")
  nodupesCheckButton = mainframe.newCheckbutton("No duplicate characters")

# -- menu
menuBar.tearoff = false
windowMenu.tearoff = false
presetsMenu.tearoff = false

root.menu = menuBar

# window menu
with menuBar.addCascade("Window"):
  menu = windowMenu

with windowMenu.addCommand("Copy Password"):
  accelerator = "Alt + C"
  underline = 0

  setCommand() do ():
    root.clipboardClear()
    root.clipboardAdd passwordEntry.get()

# presets menu
with menuBar.addCascade("Presets"):
  menu = presetsMenu

with presetsMenu.addCommand("Pin preset"):
  accelerator = "Alt + P"
  underline = 0

  setCommand() do ():
    for checkbutton in [uppercharsCheckbutton,
                        lowercharsCheckbutton,
                        digitsCheckbutton,
                        specialcharsCheckbutton,
                        nodupesCheckButton]:
      checkbutton.deselect()

    digitsCheckbutton.select()
    nodupesCheckButton.select()

    lenEntry.set $rand(4..12)

mainframe.pack(expand=true, padx=30, pady=30)

# intended ui:
#        0                         1
#     lenLabel            uppercharsCheckbutton   0
#     lenEntry            lowercharsCheckbutton   1
#     passwordEntry       digitsCheckbutton       2
#     generateButton      specialcharsCheckbutton 3   

lenLabel.grid(0, 0, padx=padx, pady=pady)
lenEntry.grid(0, 1, padx=padx, pady=pady)
passwordLabel.grid(0, 2, padx=padx, pady=pady)
passwordEntry.grid(0, 3, padx=padx, pady=pady)
generateButton.grid(0, 4, padx=padx, pady=(10, pady))

uppercharsCheckbutton.grid(1, 0)
lowercharsCheckbutton.grid(1, 1)
digitsCheckbutton.grid(1, 2)
specialcharsCheckbutton.grid(1, 3)
nodupesCheckButton.grid(1, 4)

# --- widget config

for checkbutton in [uppercharsCheckbutton, lowercharsCheckbutton, digitsCheckbutton, specialcharsCheckbutton]:
  checkbutton.select()

proc generatePassword(
  passwordLen: int,
  upperchars: bool = true,
  lowerchars: bool = true,
  digits: bool = true,
  specialchars: bool = true,
  nodupes: bool = true
): string =

  var chars: set[char]

  if upperchars: chars.incl UppercaseLetters
  if lowerchars: chars.incl LowercaseLetters
  if digits: chars.incl Digits
  if specialchars: chars.incl PunctuationChars

  if nodupes and (chars.len < passwordLen):
    raise newException(
      ValueError,
      "The password length is too long to alloq the generation of a password with " &
      "no duplicate characters"
    )

  if nodupes:
    var i: int

    while i < passwordLen:
      let char0 = chars.sample()

      if char0 in result:
        chars.excl char0
        continue

      result.add char0
      inc i

  else:
    for _ in 0..<passwordLen:
      result.add chars.sample()

generateButton.setCommand() do (_: Widget):
  let (len, upperchars, lowerchars, digits, specialchars, nodupes) = (
    parseInt lenEntry.get(),

    uppercharsCheckbutton.get(),
    lowercharsCheckbutton.get(),
    digitsCheckbutton.get(),
    specialcharsCheckbutton.get(),
    nodupesCheckbutton.get() 
  )

  try:
    if len >= 5000:
      root.busy()
      tk.update()

    passwordEntry.set generatePassword(
      len,

      upperchars,
      lowerchars,
      digits,
      specialchars,
      nodupes
    )

  except ValueError as err:
    discard root.messageBox(title="Error", message=err.msg, icon=IconImage.Error)

  finally:
    if len >= 5000:
      root.busyForget()

lenEntry.bind("<Return>") do (_: Event):
  generateButton.invoke()

root.bind("<Alt-p>") do (_: Event): presetsMenu[0].invoke()
root.bind("<Alt-P>") do (_: Event): presetsMenu[0].invoke()

root.bind("<Alt-c>") do (_: Event): windowMenu[0].invoke()
root.bind("<Alt-C>") do (_: Event): windowMenu[0].invoke()

tk.mainloop()
