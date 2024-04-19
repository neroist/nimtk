import ../src/nimtk/widgets
import ../src/nimtk/wm
import ../src/nimtk

let
  tk = newTk()
  root = tk.getRoot()

root.protocol("WM_DELETE_WINDOW", nil) do (_: Widget, _: pointer):
  root.deiconify()
  root.withdraw()

tk.mainloop()
