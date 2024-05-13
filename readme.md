# nimtk

High level wrapper for Tk

## Installation

You may install using nimble

```sh
nimble install https://github.com/neroist/nimtk
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
import ../src/nimtk/all

let
  tk = newTk()
  root = tk.getRoot()

...
```

If you want to emulate tkinter's behavior with nimtk (for whatever reason?),
`nimtk/tkinter` contains some converters which may be of use. **Still discouraged
though!**

## Wrapped widgets/commands/functionality

SUMMARY: So far only `canvas`, `text`, `panedwindow`, and ttk in its entirety have not been wrapped (rather wait until I've finished wrapping all of the classic widgets).

- [x] bell
- [x] bind
- [x] bindtags
- [x] bitmap
- [x] busy
- [x] button
- [ ] canvas
- [x] checkbutton
- [x] clipboard
- [x] colors
- [x] console
- [x] cursors
- [x] destroy
- [x] entry
- [x] event
- [x] focus
- [x] font
- [x] fontchooser
- [x] frame
- [x] geometry
- [x] grab
- [x] grid
- [x] image
- [x] keysyms
- [x] label
- [x] labelframe
- [x] listbox
- [x] lower
- [x] menu
- [x] menubutton
- [x] message
- [x] option
- [x] options
- [x] pack
- [ ] panedwindow
- [x] photo
- [x] place
- [x] radiobutton
- [x] raise
- [x] scale
- [x] scrollbar
- [x] selection
- [x] send
- [x] spinbox
- [ ] text
- [x] tk
- [ ] ~~tk::mac~~ (I currently have no way of testing or even using these functions)
- [x] tk_bisque
- [x] tk_chooseColor
- [x] tk_chooseDirectory
- [x] tk_dialog
- [x] tk_focusFollowsMouse
- [x] tk_focusNext
- [x] tk_focusPrev
- [x] tk_getOpenFile
- [x] tk_getSaveFile
- [x] tk_library
- [x] tk_menuSetFocus
- [x] tk_messageBox
- [x] tk_optionMenu
- [x] tk_patchLevel
- [x] tk_popup
- [x] tk_setPalette
- [x] tk_strictMotif
- [x] tk_textCopy
- [x] tk_textCut
- [x] tk_textPaste
- [x] tk_version
- [x] tkerror
- [x] tkwait
- [x] toplevel
- [ ] ttk::button
- [ ] ttk::checkbutton
- [ ] ttk::combobox
- [ ] ttk::entry
- [ ] ttk::frame
- [ ] ttk::intro
- [ ] ttk::label
- [ ] ttk::labelframe
- [ ] ttk::menubutton
- [ ] ttk::notebook
- [ ] ttk::panedwindow
- [ ] ttk::progressbar
- [ ] ttk::radiobutton
- [ ] ttk::scale
- [ ] ttk::scrollbar
- [ ] ttk::separator
- [ ] ttk::sizegrip
- [ ] ttk::spinbox
- [ ] ttk::style
- [ ] ttk::treeview
- [ ] ttk::widget
- [ ] ttk_image
- [ ] ttk_vsapi
- [x] winfo
- [x] wm
