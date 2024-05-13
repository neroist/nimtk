import std/sequtils
import std/strutils
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
  Photo* = ref object of Image
  Point = tuple[x, y: int]

proc toPalette(p: int or openArray[int]): string =
  when p is int:
    $p
  else:
    p.join("/")

proc flattened(coords: array[2, Point] or Point or array[4, int] or BlankOption): string =
  when coords is array[2, Point]:
    [coords[0][0], coords[0][1], coords[1][0], coords[1][1]].join(" ")
  
  elif coords is Point:
    [coords[0], coords[1]].join(" ")

  elif coords is BlankOption:
    ""
  
  else:
    coords.join(" ")

proc newPhoto*(tk: Tk): Photo {.alias: "newEmptyPhoto".} =
  new result

  result.name = genName("photo_")
  result.tk = tk

  discard tk.call("image create photo", result.name)

proc newPhoto*(
  tk: Tk,
  file: string,
  format: string = "",
  config: openArray[(string, string)] = {:}
): Photo {.alias: "newPhotoFromFile".} =
  new result

  result.name = genName("photo_")
  result.tk = tk

  tk.call(
    "image create photo",
    result.name,
    {
      "file": tclEscape file,
      "format": tclEscape format
    }.toArgs
  )

  if config.len > 0:
    result.configure(config)

proc newPhoto*(
  tk: Tk,
  data: string,
  format: string = "",
  config: openArray[(string, string)] = {:}
): Photo {.alias: "newPhotoFromData".} =
  new result

  result.name = genName("photo_")
  result.tk = tk

  tk.call(
    "image create photo",
    result.name,
    {
      "data": tclEscape data,
      "format": tclEscape format
    }.toArgs
  )

  if config.len > 0:
    result.configure(config)

proc blank*(p: Photo) = p.call("blank")
proc copy*(
  p: Photo,
  sourceImage: Photo,
  `from`: array[2, Point] or Point or BlankOption = blankOption,
  to: array[2, Point] or Point or BlankOption = blankOption,
  shrink: bool = false,
  zoom: (int, int) or BlankOption = blankOption,
  subsample: (int, int) or BlankOption = blankOption,
  compositingrule: string or BlankOption = blankOption
) =
  p.call(
    "data",
    {
      "from": `from`.flattened(),
      "to": to.flattened(),
      "shrink":
        if shrink:
          " "
        else:
          "",
      "zoom": zoom.flattened(),
      "subsample": zoom.flattened(),
      "compositingrule": tclEscape compositingrule
    }.toArgs
  )
proc data*(
  p: Photo,
  background: Color or BlankOption = blankOption,
  format: string or BlankOption = blankOption,
  `from`: array[2, Point] or Point or BlankOption = blankOption,
  grayscale: bool = false
): string =
  p.call(
    "data",
    {
      "background": $background,
      "format": tclEscape format,
      "from": `from`.flattened(),
      "greyscale":
        if grayscale:
          " "
        else:
          ""
    }.toArgs
  )
proc get*(p: Photo): Color =
  let rgbLst = p.call("get").split(' ').map(parseInt)

  rgb(rgbLst[0], rgbLst[1], rgbLst[2])
proc put*(
  p: Photo,
  data: string,
  to: array[2, Point] or Point or BlankOption = blankOption,
  format: string = "",
) =
  p.call(
    "put",
    tclEscape data,
    {
      "to": to.flattened(),
      "format": tclEscape $format,
    }.toArgs
  )
proc read*(
  p: Photo,
  filename: string,
  to: Point or BlankOption = blankOption,
  format: string = "",
  `from`: array[2, Point] or Point or BlankOption = blankOption,
  shrink: bool = false
) =
  p.call(
    "read",
    tclEscape filename,
    {
      "to": to.flattened(),
      "format": tclEscape $format,
      "from": `from`.flattened(),
      "shrink":
        if shrink:
          " "
        else:
          ""
    }.toArgs
  )
proc redither*(p: Photo) = p.call("redither")
proc transparencyGet*(p: Photo, x, y: int): bool = p.call("transparency get", x, y) == "1"
proc transparencySet*(p: Photo, x, y: int, transparency: bool) = p.call("transparency set", x, y, transparency)
proc write*(
  p: Photo,
  filename: string,
  background: Color or BlankOption = blankOption,
  format: string = "",
  `from`: array[2, Point] or Point or BlankOption = blankOption,
  grayscale: bool = false
) =
  p.call(
    "write",
    tclEscape filename,
    {
      "background": tclEscape $background,
      "format": tclEscape $format,
      "from": `from`.flattened(),
      "greyscale":
        if grayscale:
          " "
        else:
          ""
    }.toArgs
  )

proc `data=`*(p: Photo, data: string) = p.configure({"data": tclEscape $data})
proc `format=`*(p: Photo, format: string) = p.configure({"format": tclEscape $format})
proc `file=`*(p: Photo, file: string) = p.configure({"file": tclEscape $file})
proc `gamma=`*(p: Photo, gamma: int or float) = p.configure({"gamma": $gamma})
proc `height=`*(p: Photo, height: int) = p.configure({"height": $height})
proc `palette=`*(p: Photo, palette: int or openArray[int]) = p.configure({"palette": palette.toPalette()})
proc `width=`*(p: Photo, maskfile: int) = p.configure({"maskfile": tclEscape $maskfile})

proc background*(p: Photo): Color = fromTclColor p, p.cget("background")
proc cget_data*(p: Photo): string = p.cget("data")
proc file*(p: Photo): string = p.cget("file")
proc foreground*(p: Photo): Color = fromTclColor p, p.cget("foreground")
proc maskdata*(p: Photo): string = p.cget("maskdata")
proc maskfile*(p: Photo): string = p.cget("maskfile")
