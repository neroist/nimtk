import std/strutils

import ../../nimtk

type
  Image* = ref object of RootObj
    tk*: Tk
    name*: string

proc `$`*(i: Image): string = i.name

proc createImage*(tk: Tk, name: string): Image =
  new result

  result.tk = tk
  result.name = name

proc delete*(i: Image) = i.tk.call("image delete", i)

proc height*(i: Image): float =
  i.tk.call("image height", i).parseFloat()

proc inuse*(i: Image): bool =
  i.tk.call("image inuse", i) == "1"

proc names*(tk: Tk): seq[Image] =
  tk.call("image names")

  for i in tk.result.split():
    let image = new Image

    image.name = i
    image.tk = tk

proc type*(i: Image): string =
  i.tk.call("image type", i)

proc types*(tk: Tk): seq[string] =
  tk.call("image types").split()

proc width*(i: Image): float =
  i.tk.call("image width", i).parseFloat()
