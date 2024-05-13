from std/strutils import replace

type
  BlankOption* = distinct string
    ## Distinct type for a blank option, for use with `toArgs`, which ignores any
    ## option with a blank value.
    ##
    ## When passed into `tclEscape`, an empty string will always be returned.

const
  escChars* = {'[', ']', '{' ,'}', '$'}
    ## These characters in Tcl strings must be escaped

  blankOption* = BlankOption ""
    ## `BlankOption` string to use as default args in functions

proc `$`*(_: BlankOption): string = ""
  ## "Convert" a `BlankOption` into a string. Will always return an empty string.

proc tclEscape*(str: string): string =
  ## Escape strings in a way that is acceptable to Tcl
  ##
  ## Characters such as `'['`, `']'`, and `'$'` are integral parts of Tcl's syntax and may
  ## cause errors when unescaped.
  ##
  ## :str: The string to escape

  # lets have repr do some of the work for us
  result = repr str

  # escape the characters in `escChars` ("[" -> "\[")
  for escChar in escChars:
    result = result.replace($escChar, '\\' & escChar)

proc tclEscape*(_: BlankOption): string = ""
  ## "Escape" a `BlankOption`. Always returns an empty string.

proc tclEscape*[T](val: T and not BlankOption and not string): string = tclEscape $val
  ## Escape values without needing to stringify them beforehand
