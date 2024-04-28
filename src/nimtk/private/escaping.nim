from std/strutils import replace

const
  escChars* = {'[', ']', '{' ,'}', '$'}
    ## These characters in Tcl strings must be escaped

proc tclEscape*(str: string): string =
  ## Escape strings in a way that is acceptable to Tcl
  ##
  ## Characters such as '[', ']', and '$' are integral parts of Tcl's syntax and may
  ## cause errors when unescaped.

  # lets have repr do some of the work for us
  result = repr str

  # escape the characters in `escChars` ("[" -> "\[")
  for escChar in escChars:
    result = result.replace($escChar, '\\' & escChar)
