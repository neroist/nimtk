import std/strutils
import std/colors
import std/times

import nimtk/all

const dateFmt = "dd-MM-yyyy"

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Flight Booker"
root.geometry("300x200")

let
  mainframe = root.newFrame()

  flightSpinbox = mainframe.newSpinbox(["one-way flight", "return flight"])
  startDateEntry = mainframe.newEntry(now().format(dateFmt))
  returnDateEntry = mainframe.newEntry((now() + initDuration(days=2)).format(dateFmt))
  bookButton = mainframe.newButton("Book")

  defaultEntryBackground = startDateEntry.background()

mainframe.pack(expand=true, padx=10, pady=10)

flightSpinbox.wrap = true
returnDateEntry.state = wsReadonly

flightSpinbox.grid(padx=5, pady=5)
startDateEntry.grid(padx=5, pady=5)
returnDateEntry.grid(padx=5, pady=5)
bookButton.grid(padx=5, pady=5)

proc validation(widget: Widget, event: EntryEvent): bool =
  # til, for example, if this func is being called on `returnDateEntry`
  # you musnt call `returnDateEntry.get()
  
  result = true

  try:
    let currDate = event.editedValue.parse(dateFmt)

    # TODO fix this...
    if widget == startDateEntry:
      if currDate > returnDateEntry.get().parse(dateFmt):
        bookButton.state = wsDisabled
        widget.background = colRed

        return
    else:
      if currDate < startDateEntry.get().parse(dateFmt):
        bookButton.state = wsDisabled
        widget.background = colRed

        return

    bookButton.state = wsNormal
    widget.background = defaultEntryBackground
  except TimeParseError:
    bookButton.state = wsDisabled
    widget.background = colRed

for entry in [startDateEntry, returnDateEntry]:
  entry.config(
    validatecommand = validation,
    validationMode = vmKey
  )

flightSpinbox.setCommand() do (_: Widget, _: string):
  if flightSpinbox.get() == "return flight":
    returnDateEntry.state = wsNormal
  else:
    returnDateEntry.state = wsReadonly

bookButton.setCommand() do (_: Widget):
  discard root.messageBox(
    "Flight Booked",
    "You have booked a $1 on $2" % [flightSpinbox.get(), startDateEntry.get()]
  )

tk.mainloop()
