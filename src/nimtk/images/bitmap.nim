import std/colors

import ../private/commands
import ../private/tclcolor
import ../private/escaping
import ../private/genname
import ../private/toargs
import ../private/alias
import ../../nimtk
import ./image

type
  Bitmap* = ref object of Image

proc newBitmap*(tk: Tk, file: string, config: openArray[(string, string)] = {:}): Bitmap {.alias: "newBitmapFromFile".} =
  new result

  result.name = genName("bitmap_")
  result.tk = tk

  tk.call("image create bitmap", result.name)

  result.configure({"file": tclEscape file})

  if config.len > 0:
    result.configure(config)

proc newBitmap*(tk: Tk, data: string, config: openArray[(string, string)] = {:}): Bitmap {.alias: "newBitmapFromData".} =
  new result

  result.name = genName("bitmap_")
  result.tk = tk

  tk.call("image create bitmap", result.name)

  result.configure({"data": tclEscape data})

  if config.len > 0:
    result.configure(config)

proc `background=`*(b: Bitmap, background: Color) = b.configure({"background": $background})
proc `data=`*(b: Bitmap, data: string) = b.configure({"data": tclEscape $data})
proc `file=`*(b: Bitmap, file: string) = b.configure({"file": tclEscape $file})
proc `foreground=`*(b: Bitmap, foreground: Color) = b.configure({"foreground": $foreground})
proc `maskdata=`*(b: Bitmap, maskdata: string) = b.configure({"maskdata": tclEscape $maskdata})
proc `maskfile=`*(b: Bitmap, maskfile: string) = b.configure({"maskfile": tclEscape $maskfile})

proc background*(b: Bitmap): Color = fromTclColor b, b.cget("background")
proc data*(b: Bitmap): string = b.cget("data")
proc file*(b: Bitmap): string = b.cget("file")
proc foreground*(b: Bitmap): Color = fromTclColor b, b.cget("foreground")
proc maskdata*(b: Bitmap): string = b.cget("maskdata")
proc maskfile*(b: Bitmap): string = b.cget("maskfile")
