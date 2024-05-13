type
  TkError* = object of CatchableError
    ## Base, generic exception raised by nimtk on any errors from Tcl.
