import ../nimtk
import ./widget

type
  Root* = ref object of Widget

proc getRoot*(tk: Tk): Root =
  new result

  result.pathname = "."
  result.tk = tk
