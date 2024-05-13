import std/sequtils
import std/strutils
import std/colors

import ../private/commands
import ../private/escaping
import ../private/genname
import ../private/toargs
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

proc flattened(coords: array[2, Point] or Point or int or BlankOption): string =
  when coords is array[2, Point]:
    [coords[0][0], coords[0][1], coords[1][0], coords[1][1]].join(" ")
  
  elif coords is Point:
    [coords[0], coords[1]].join(" ")

  elif coords is BlankOption:
    ""

  elif coords is int:
    $coords
  
  else:
    coords.join(" ")

proc newPhoto*(tk: Tk): Photo =
  new result

  result.name = genName("photo_")
  result.tk = tk

  discard tk.call("image create photo", result.name)

proc newPhoto*(
  tk: Tk,
  file: string;
  format: string = "", 
  config: openArray[(string, string)] = {:}
): Photo =
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

proc newPhotoFromData*(
  tk: Tk,
  data: string;
  format: string = "",
  config: openArray[(string, string)] = {:}
): Photo =
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
  zoom: (int, int) or int or BlankOption = blankOption,
  subsample: (int, int) or int or BlankOption = blankOption,
  compositingrule: string or BlankOption = blankOption
) =
  p.call(
    "copy",
    $sourceImage,
    {
      "from": `from`.flattened(),
      "to": to.flattened(),
      "shrink":
        if shrink:
          " "
        else:
          "",
      "zoom": zoom.flattened(),
      "subsample": subsample.flattened(),
      "compositingrule": tclEscape compositingrule
    }.toArgs
  )
proc zoom*(p: Photo, x: int; y: int = x): Photo =
  result = p.tk.newPhoto()
  
  result.copy(p, zoom=(x, y))
proc subsample*(p: Photo, x: int; y: int = x): Photo =
  result = p.tk.newPhoto()
  
  result.copy(p, subsample=(x, y))
proc compositingrule*(p: Photo, compositingrule: string): Photo =
  result = p.tk.newPhoto()
  
  result.copy(p, compositingrule=compositingrule)
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

proc `data=`*(p: Photo, data: string) = p.configure({"data": tclEscape data})
proc `format=`*(p: Photo, format: string) = p.configure({"format": tclEscape format})
proc `file=`*(p: Photo, file: string) = p.configure({"file": tclEscape file})
proc `gamma=`*(p: Photo, gamma: int or float) = p.configure({"gamma": $gamma})
proc `height=`*(p: Photo, height: int) = p.configure({"height": $height})
proc `palette=`*(p: Photo, palette: int or openArray[int]) = p.configure({"palette": palette.toPalette()})
proc `width=`*(p: Photo, width: int) = p.configure({"width": $width})

proc cget_data*(p: Photo): string = p.cget("data")
proc format*(p: Photo): string = p.cget("format")
proc file*(p: Photo): string = p.cget("file")
proc gamma*(p: Photo): float = parseFloat p.cget("gamma")
proc height*(p: Photo): int = parseInt p.cget("height")
proc palette*(p: Photo): seq[int] = p.cget("palette").split('/').map(parseInt)
proc width*(p: Photo): int = parseInt p.cget("width")

