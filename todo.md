These should be sorted by urgency/importance

---

- [ ] Support not deciding for the dev, for `toArgs`, options with no value (`value.len == 0`), the option is ignored. this may be used to wrap functions such as `rowconfigure` and `columnconfigure` or other functions which are wraped via default values
    
    In summary, dont use default values and instead use `""`

- [ ] On creation of a new widget, always create a default `textvariable` for the widget (and `variable` too, if applicable). This allows `set` and `get` procs for getting the value of the widget (varible) without needing to create a new TkVar

- [ ] Should we keep the `clientdata` parameters in `Tk*Command` proc types?

- [ ] For all strings passed to Tcl, use `tclEscape`, or some kind of escaping function

- [ ] Use multiple aliases in procs (even though it breaks the syntax highlighting)

- [ ] Reduce code duplication and use templates & macros when needed
    - [ ] Create a `setCommand` template similar to the procs in `widgets/**`

- [x] `configure` macro that transforms code like this

```nim
button.configure(
    text = "hi!",
    foreground = colAliceBlue,
    relief = WidgetRelief.Groove
)
```

into this

```nim
button.text = "hi!",
button.foreground = colAliceBlue,
button.relief = WidgetRelief.Groove
```

- [ ] All widget creation procs should accept a `configuration` argument which is of type `openArray[(string, string)]` and is passed to `result.configure`

- [ ] Try to merge `Root` and `Tk`

- [ ] Add documenation (<https://www.tcl.tk/man/tcl8.6/>)

- [ ] Learn from `tkinter` and other tk wrappers