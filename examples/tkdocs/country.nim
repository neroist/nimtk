import std/sequtils
import std/strutils
import std/tables
import std/colors

import nimtk/all

const
  countryNames = [
    "Argentina",
    "Australia",
    "Belgium",
    "Brazil",
    "Canada",
    "China",
    "Denmark",
    "Finland",
    "France",
    "Greece",
    "India",
    "Italy",
    "Japan",
    "Mexico",
    "Netherlands",
    "Norway",
    "Spain",
    "Sweden",
    "Switzerland"
  ]

  populations = {
    "ar": 41_000_000,
    "au": 21_179_211,
    "be": 10_584_534,
    "br": 185_971_537,
    "ca": 33_148_682,
    "cn": 1_323_128_240,
    "dk": 5_457_415,
    "fi": 5_302_000,
    "fr": 64_102_140,
    "gr": 11_147_000,
    "in": 1_131_043_000,
    "it": 59_206_382,
    "jp": 127_718_000,
    "mx": 106_535_000,
    "nl": 16_402_414,
    "no": 4_738_085,
    "es": 45_116_894,
    "se": 9_174_082,
    "ch": 7_508_700
  }.toTable()

  countryCodes = toSeq populations.keys

  altListboxBg = Color 0xf0f0ff

  (N, W, E, S) = (
    AnchorPosition.North,
    AnchorPosition.West,
    AnchorPosition.East,
    AnchorPosition.South
  )

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Country selector listbox example"

let
  # main containers
  mainframe = root.newFrame()

  # variables/state
  giftVar = tk.newTkString("Greeting card")

  # widgets
  countriesListbox = mainframe.newListbox(countryNames)
  sendToLabel = mainframe.newLabel("Send to country's leader:")
  cardRadiobutton = mainframe.newRadiobutton("Greeting card")
  flowersRadiobutton = mainframe.newRadiobutton("Flowers")
  nastyGramRadiobutton = mainframe.newRadiobutton("Nastygram")
  sendButton = mainframe.newButton("Send Gift")
  sentLabel = mainframe.newLabel()
  populationLabel = mainframe.newLabel()

proc showPopulation(_: Event = Event()) =
  ## Called when the selection in the listbox changes 

  # if nothing is selected, return
  if len(countriesListbox.curselection) != 1: return

  # figure out which country is currently selected, and then lookup its country
  # code, and from that, its population.
  let 
    index = countriesListbox.curselection[0]
  
    (countryName, countryCode) = (
      countryNames[index],
      countryCodes[index] 
    )

    population = populations[countryCode] # 

  # Update the population label with the new population
  populationLabel.text = "The population of $1 ($2) is $3" % [countryName, countryCode, $population]
  
  # clear the message about the gift being sent, so it doesn't stick around after we
  # start doing ther things.
  sentLabel.text = ""

proc sendGift(_: Event = Event()) =
  ## Called when the user double clicks an item in the listbox, presses
  ## the "Send Gift" button, or presses the Return key.  
  
  # if nothing is selected, return
  if len(countriesListbox.curselection) != 1: return

  # In case the selected item is scrolled out of view, make sure it is visible.
  countriesListbox.see(
    countriesListbox.curselection[0] # index of current selection
  )

  sentLabel.text = "Sent $1 to leader of $2" % [
    giftVar.get(), # get the value of the var. you can also use `$` (but why?)
    countriesListbox.selection[0] # get the value of the current selection (as opposed to index of current selection)
  ]

# grid all widgets & frames
mainframe.grid(0, 0, pady=5, padx=(12, 0), sticky = @[N, S, W, E])
root.grid_columnconfigure(0, weight=1)
root.grid_rowconfigure(0, weight=1)

countriesListbox.grid(0, 0, rowspan=6, sticky = @[N, S, W, E])
sendToLabel.grid(1, 0, padx=10, pady=5)
cardRadiobutton.grid(1, 1, sticky=AnchorPosition.West, padx=20)
flowersRadiobutton.grid(1, 2, sticky=AnchorPosition.West, padx=20)
nastyGramRadiobutton.grid(1, 3, sticky=AnchorPosition.West, padx=20)
sendButton.grid(2, 4, sticky=AnchorPosition.East, padx=5)
sentLabel.grid(1, 5, sticky=AnchorPosition.North, pady=5, padx=5)
populationLabel.grid(0, 6, columnspan=2, sticky = @[AnchorPosition.West, AnchorPosition.East])

mainframe.grid_columnconfigure(0..1, weight=1)
mainframe.grid_rowconfigure(0..6, weight=1)

# -- config radio buttons
# anything else, and they go into "tristate mode"
# `giftVar` must also be set to one of the radiobuttons' value (if not, it starts out as
# tristate, and changes upon one of the radiobuttons being selected)
cardRadiobutton.value = "Greeting card"
flowersRadiobutton.value = "Flowers"
nastyGramRadiobutton.value = "Nastygram"

cardRadiobutton.variable = giftVar
flowersRadiobutton.variable = giftVar
nastyGramRadiobutton.variable = giftVar

# -- listbox config
# colorize alternating lines of the listbox
for itemIndex in countup(0, countryNames.len, 2):
  countriesListbox.itemconfigure(itemIndex, background=altListboxBg)

countriesListbox.selection = 0

# because the <<ListboxSelect>> event is only
# fired when users makes a change, we explicitly call showPopulation
showPopulation()

# bind procs
countriesListbox.bind("<<ListboxSelect>>", showPopulation)

countriesListbox.bind("<Double-1>", sendGift)
root.bind("<Return>", sendGift)

sendButton.setCommand() do (_: Widget):
  sendGift()

tk.mainloop()
