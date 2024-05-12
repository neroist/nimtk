## Module to mimic Tkinter's behavior of letting `Tk` and
## the root window be the same object

import ./widgets/root
import ./nimtk

converter rootToTk*(r: Root): Tk = r.tk
converter tkToRoot*(tk: Tk): Root = tk.getRoot()
