import std/strutils

import ../../nimtk

type
  Image* = ref object of RootObj
    tk*: Tk
    name*: string

proc `$`*(i: Image): string = i.name

proc delete*(i: Image) = i.tk.call("image delete", i)

proc height*(i: Image): float =
  i.tk.call("image height", i)
  i.tk.result.parseFloat()

proc inuse*(i: Image): bool =
  i.tk.call("image inuse", i)
  i.tk.result == "1"

proc names*(tk: Tk): seq[Image] =
  tk.call("image names")

  for i in tk.result.split():
    let image = new Image

    image.name = i
    image.tk = tk

proc type*(i: Image): string =
  i.tk.call("image type", i)
  i.tk.result

proc types*(tk: Tk): seq[string] =
  tk.call("image types")
  tk.result.split()

proc width*(i: Image): float =
  i.tk.call("image width", i)
  i.tk.result.parseFloat()
