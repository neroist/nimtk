# nimtk

High level wrapper for Tk

## Installation

You may install using nimble

```sh
nimble install nimtk
```

This library only depends upon [`nimtcl`](https://github.com/neroist/nimtcl).

## Usage/Documentation

Please see the [examples](/examples/) for library usage. This wrapper should be
*similar enough* to tkinter and Tk to still be intuitive to use.

## Differences from tkinter

In tkinter, the `Tk` object both serves as a the Tcl interpreter and the root window
in for Tk. Instead, this is separated in `nimtk`, in which `Tk` only holds the Tcl
interpreter, and `Root` is the root window. Below is common code in all of the
examples:

```nim
import nimtk/all

let
  tk = newTk()
  root = tk.getRoot()

...
```

If you want to emulate tkinter's behavior with nimtk (for whatever reason?),
`nimtk/tkinter` contains some converters which may be of use. **Still discouraged
though!**

## Wrapped functionality from Tk

See https://github.com/neroist/nimtk/issues/1