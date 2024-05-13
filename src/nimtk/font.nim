import std/strutils

import ./utils/escaping
import ./utils/genname
import ./utils/tcllist
import ./utils/toargs
import ./widgets/widget
import ./utils/alias
import ./widgets/root
import ../nimtk

proc `$`*(f: Font): string =
  if f.isNil(): ""
  else: f.fontname

proc newFont*(
  tk: Tk,
  family: string,
  size: int,
  weight: FontWeight = FontWeight.Normal,
  slant: FontSlant = FontSlant.Roman,
  underline: bool = false,
  overstrike: bool = false
): Font =
  new result

  result.fontname = genName("font_")
  result.tk = tk

  discard result.tk.call(
    "font create",
    result.fontname,
    {
      "family": tclEscape family,
      "size": $size,
      "weight": $weight,
      "slant": $slant,
      "underline": $underline,
      "overstrike": $overstrike
    }.toArgs()
  )

proc newFont*(
  tk: Tk,
  description: string
): Font =
  ## Creates new font with font description `description`
  ##
  ## See https://www.tcl.tk/man/tcl8.6/TkCmd/font.htm#M13 for font descriptions
  ## accepted by Tk
  ##
  ## .. note:: for the 3rd font description format
  ##           family MUST not contain spaces
  ##           
  ##           if the family name contains spaces, simply
  ##           remove them.
  ##           
  ##           EX: "Fira Code 16" -> "FiraCode 16"
  ##
  ## :description: Font description to create the font from.

  new result

  result.fontname = genName("font_")
  result.tk = tk

  discard result.tk.call(
    "font create",
    result.fontname,
    tk.call("font actual", tclEscape description)
  )

proc delete*(f: Font) = f.tk.call("font delete", f)
proc families*(w: Widget): seq[string] = w.tk.fromTclList w.tk.call("font families", {"displayof": $w}.toArgs)
proc names*(tk: Tk): seq[Font] {.alias: "fonts".} =
  tk.call("font names")

  for fontname in tk.fromTclList(tk.result):
    let font = new Font

    font.tk = tk
    font.fontname = fontname

    result.add font
proc measure*(f: Font, w: Widget, text: string): int = parseInt f.tk.call("font measure", f, {"displayof": $w}.toArgs, tclEscape text)
proc measure*(f: Font, text: string): int = parseInt f.tk.call("font measure", f, tclEscape text)
proc metrics*(f: Font, w: Widget, option: string): string = f.tk.call("font metrics", {"displayof": $w}.toArgs, tclEscape option)
proc metrics*(f: Font, option: string): string = f.tk.call("font metrics", tclEscape option)
proc actual*(f: Font, w: Widget, option: string): string = f.tk.call("font actual", {"displayof": $w}.toArgs, tclEscape option)
proc actual*(f: Font, option: string): string = f.tk.call("font actual", tclEscape option)
# * configure is defined by widgets.nim for us!

# metrics sub-procs
proc ascent*(f: Font, w: Widget = nil): int    = parseInt f.tk.call("font metrics", f, {"displayof": $w}.toArgs, "-ascent")
proc descent*(f: Font, w: Widget = nil): int   = parseInt f.tk.call("font metrics", f, {"displayof": $w}.toArgs, "-descent")
proc linespace*(f: Font, w: Widget = nil): int = parseInt f.tk.call("font metrics", f, {"displayof": $w}.toArgs, "-linespace")
proc fixed*(f: Font, w: Widget = nil): bool    = f.tk.call("font metrics", f, {"displayof": $w}.toArgs, "-fixed") == "1"

# configure sub-procs
proc family*(f: Font): string     = f.tk.call("font configure", f, "-family")
proc size*(f: Font): int          = parseInt f.tk.call("font configure", f, "-size")
proc weight*(f: Font): FontWeight = parseEnum[FontWeight] f.tk.call("font configure", f, "-weight")
proc slant*(f: Font): FontSlant   = parseEnum[FontSlant] f.tk.call("font configure", f, "-slant")
proc underline*(f: Font): bool    = f.tk.call("font configure", f, "-underline")  == "1"
proc overstrike*(f: Font): bool   = f.tk.call("font configure", f, "-overstrike") == "1"

proc `family=`*(f: Font, family: string)       = f.tk.call("font configure", f, "-family", tclEscape family)
proc `size=`*(f: Font, size: int)              = f.tk.call("font configure", f, "-size", size)
proc `weight=`*(f: Font, weight: FontWeight)   = f.tk.call("font configure", f, "-weight", weight)
proc `slant=`*(f: Font, slant: FontSlant)      = f.tk.call("font configure", f, "-slant", slant)
proc `underline=`*(f: Font, underline: bool)   = f.tk.call("font configure", f, "-underline", underline)
proc `overstrike=`*(f: Font, overstrike: bool) = f.tk.call("font configure", f, "-overstrike", overstrike)

# actual sub-procs
proc actualFamily*(f: Font, w: Widget = nil): string     = f.tk.call("font actual", f, {"displayof": $w}.toArgs, "-family")
proc actualSize*(f: Font, w: Widget = nil): int          = parseInt f.tk.call("font actual", f, {"displayof": $w}.toArgs, "-size")
proc actualWeight*(f: Font, w: Widget = nil): FontWeight = parseEnum[FontWeight] f.tk.call("font actual", f, {"displayof": $w}.toArgs, "-weight")
proc actualSlant*(f: Font, w: Widget = nil): FontSlant   = parseEnum[FontSlant] f.tk.call("font actual", f, {"displayof": $w}.toArgs, "-slant")
proc actualUnderline*(f: Font, w: Widget = nil): bool    = f.tk.call("font actual", f, {"displayof": $w}.toArgs, "-underline")  == "1"
proc actualOverstrike*(f: Font, w: Widget = nil): bool   = f.tk.call("font actual", f, {"displayof": $w}.toArgs, "-overstrike") == "1"

proc actualFamily*(f: Font, w: Widget = nil, c: char): string     = f.tk.call("font actual", f, {"displayof": $w}.toArgs, "-family", "--", c)
proc actualSize*(f: Font, w: Widget = nil, c: char): int          = parseInt f.tk.call("font actual", f, {"displayof": $w}.toArgs, "-size", "--", c)
proc actualWeight*(f: Font, w: Widget = nil, c: char): FontWeight = parseEnum[FontWeight] f.tk.call("font actual", f, {"displayof": $w}.toArgs, "-weight", "--", c)
proc actualSlant*(f: Font, w: Widget = nil, c: char): FontSlant   = parseEnum[FontSlant] f.tk.call("font actual", f, {"displayof": $w}.toArgs, "-slant", "--", c)
proc actualUnderline*(f: Font, w: Widget = nil, c: char): bool    = f.tk.call("font actual", f, {"displayof": $w}.toArgs, "-underline", "--", c)  == "1"
proc actualOverstrike*(f: Font, w: Widget = nil, c: char): bool   = f.tk.call("font actual", f, {"displayof": $w}.toArgs, "-overstrike", "--", c) == "1"

# widget methods
proc font*(w: Widget): Font =
  new result
  
  result.fontname = w.cget("font")
proc `font=`*(w: Widget, font: Font) = w.configure({"font": $font})

# fontchooser
proc fontchooser*(w: Widget, title: string = "", font: Font = nil, command: TkFontCommand = nil) =
  var cmdname: string

  if command != nil:
    cmdname = genName("fontchooser_command_")
    w.tk.registerCmd(cmdname, command)
  else:
    cmdname = "\"\""
  
  w.tk.call(
    "tk fontchooser configure",
    {
      "title": tclEscape title,
      "font": $font,
      "command": cmdname,
      "parent": $w
    }.toArgs
  )
proc fontchooser*(tk: Tk, title: string = "", font: Font = nil, command: TkFontCommand = nil) =
  # this proc is preferred over the other one, for consistency reasons
  fontchooser(tk.getRoot(), title, font, command)

proc fontchooserVisible*(tk: Tk): bool = tk.call("tk fontchooser configure -visible") == "1"
proc fontchooserTitle*(tk: Tk): string = tk.call("tk fontchooser configure -title")
proc fontchooserFont*(tk: Tk): Font =
  new result
  
  let fontname = tk.call("tk fontchooser configure -font")

  result.tk = tk
  result.fontname = fontname
proc fontchooserCommand*(tk: Tk) {.alias: "fontchooserInvoke".} = tk.call("tk fontchooser configure -command")
  ## Calls the command registered for the fontchoooser

proc fontchooserShow*(tk: Tk) = tk.call("tk fontchooser show")
proc fontchooserHide*(tk: Tk) = tk.call("tk fontchooser Hide")

