import std/colors

import ../../nimtk
import ../widgets
import ./image

type
  Bitmap* = ref object of Image

proc newBitmap*(tk: Tk, file: string, config: openArray[(string, string)] = {:}): Bitmap =
  new result

  result.name = genName("bitmap_")
  result.tk = tk

  tk.call("image create bitmap", result.name)

  result.configure({"file": repr file})

  if config.len > 0:
    result.configure(config)

proc newBitmap*(tk: Tk, data: string, config: openArray[(string, string)] = {:}): Bitmap =
  new result

  result.name = genName("bitmap_")
  result.tk = tk

  tk.call("image create bitmap", result.name)

  result.configure({"data": repr data})

  if config.len > 0:
    result.configure(config)

proc `bitmap=`*(w: Widget, bitmap: Bitmap or string) =
  when bitmap is string:
    w.configure({"bitmap": $bitmap})
  else:
    w.configure({"image": $bitmap})

proc bitmap*(w: Widget): Bitmap =
  new result
  
  result.name = w.cget("bitmap")
  result.tk = w.tk

proc `background=`*(b: Bitmap, background: Color) = b.configure({"background": $background})
proc `data=`*(b: Bitmap, data: string) = b.configure({"data": $data})
proc `file=`*(b: Bitmap, file: string) = b.configure({"file": $file})
proc `foreground=`*(b: Bitmap, foreground: Color) = b.configure({"foreground": $foreground})
proc `maskdata=`*(b: Bitmap, maskdata: string) = b.configure({"maskdata": $maskdata})
proc `maskfile=`*(b: Bitmap, maskfile: string) = b.configure({"maskfile": $maskfile})

proc background*(b: Bitmap): Color = parseColor b.cget("background")
proc data*(b: Bitmap): string = b.cget("data")
proc file*(b: Bitmap): string = b.cget("file")
proc foreground*(b: Bitmap): Color = parseColor b.cget("foreground")
proc maskdata*(b: Bitmap): string = b.cget("maskdata")
proc maskfile*(b: Bitmap): string = b.cget("maskfile")
