import nimtk/all

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Hello World!"
root.geometry = "300x200"

let
  label = root.newLabel("Hello World!")

label.pack(fill="both", expand=true)

tk.mainloop()
