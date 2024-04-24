import std/strutils
import std/random

import ../src/nimtk/widgets/entry
import ../src/nimtk/widgets
import ../src/nimtk/tcl
import ../src/nimtk/wm
import ../src/nimtk

randomize()

const
  padx = 4
  pady = 4

# TODO feat: menu item for copying password

let
  tk = newTK()
  root = tk.getRoot()

root.title = "Password Generator"
root.resizable = false

let
  mainframe = root.newFrame()

  lenLabel = mainframe.newLabel("How many characters should be in the password?")
  lenEntry = mainframe.newEntry($rand(16..64))

  passwordLabel = mainframe.newLabel("Password:")
  passwordEntry = mainframe.newEntry()

  generateButton = mainframe.newButton("Generate!")

  uppercharsCheckbutton = mainframe.newCheckbutton("Uppercase characters (A-Z)")
  lowercharsCheckbutton = mainframe.newCheckbutton("Lowercase characters (A-Z)")
  digitsCheckbutton = mainframe.newCheckbutton("Digits (0-9)")
  specialcharsCheckbutton = mainframe.newCheckbutton("Special characters")
  nodupesCheckButton = mainframe.newCheckbutton("No duplicate characters")

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

generateButton.setCommand(nil) do (_: Widget, _: pointer):
  let (len, upperchars, lowerchars, digits, specialchars, nodupes) = (
    parseInt lenEntry.get(),

    uppercharsCheckbutton.get(),
    lowercharsCheckbutton.get(),
    digitsCheckbutton.get(),
    specialcharsCheckbutton.get(),
    nodupesCheckbutton.get() 
  )

  try:
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
    discard root.messageBox(err.msg, title="Error", icon=IconImage.Error)
  finally:
    root.busyForget()

tk.mainloop()
