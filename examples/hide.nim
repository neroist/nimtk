import nimtk/all

let
  tk = newTk()
  root = tk.getRoot()

root.title = "Hide"

root.protocol("WM_DELETE_WINDOW") do (_: Widget):
  root.deiconify()
  root.withdraw()

tk.mainloop()
