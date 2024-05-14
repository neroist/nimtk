import std/strutils

import nimtk/all

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Temperature Converter"

let
  celsiusEntry = root.newEntry("0")
  celsiusLabel = root.newLabel("Celsius")

  eqLabel = root.newLabel("=")

  fahrenheitEntry = root.newEntry("32")
  fahrenheitLabel = root.newLabel("Fahrenheit")

celsiusEntry.grid(0, 0, padx=5, pady=5)
celsiusLabel.grid(1, 0, padx=5, pady=5)
eqLabel.grid(2, 0, padx=5, pady=5)
fahrenheitEntry.grid(3, 0, padx=5, pady=5)
fahrenheitLabel.grid(4, 0, padx=5, pady=5)

fahrenheitEntry.bind("<Key>") do (_: Event):
  let fahrenheit = 
    try:
      parseFloat fahrenheitEntry.get()
    except ValueError:
      0'f
  
  celsiusEntry.set $((fahrenheit - 32) * 5/9)

celsiusEntry.bind("<Key>") do (_: Event):
  let celsius =
    try: 
      parseFloat celsiusEntry.get()
    except ValueError:
      0'f

  fahrenheitEntry.set $((celsius * 9/5) + 32)

tk.mainloop()
