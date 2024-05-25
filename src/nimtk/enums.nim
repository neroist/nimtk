## Enums used by nimtk. All are pure enums, with the exception of keysyms.

type
  Cursor* = enum
    curXCursor = "X_cursor"
    curArrow = "arrow"
    curBasedArrowDown = "based_arrow_down"
    curBasedArrowUp = "based_arrow_up"
    curBoat = "boat"
    curBogosity = "bogosity"
    curBottomLeftCorner = "bottom_left_corner"
    curBottomRightCorner = "bottom_right_corner"
    curBottomSide = "bottom_side"
    curBottomTee = "bottom_tee"
    curBoxSpiral = "box_spiral"
    curCenterPtr = "center_ptr"
    curCircle = "circle"
    curClock = "clock"
    curCoffeeMug = "coffee_mug"
    curCross = "cross"
    curCrossReverse = "cross_reverse"
    curCrosshair = "crosshair"
    curDiamondCross = "diamond_cross"
    curDot = "dot"
    curDotbox = "dotbox"
    curDoubleArrow = "double_arrow"
    curDraftLarge = "draft_large"
    curDraftSmall = "draft_small"
    curDrapedBox = "draped_box"
    curExchange = "exchange"
    curFleur = "fleur"
    curGobbler = "gobbler"
    curGumby = "gumby"
    curHand1 = "hand1"
    curHand2 = "hand2"
    curHeart = "heart"
    curIcon = "icon"
    curIronCross = "iron_cross"
    curLeftPtr = "left_ptr"
    curLeftSide = "left_side"
    curLeftTee = "left_tee"
    curLeftbutton = "leftbutton"
    curLlAngle = "ll_angle"
    curLrAngle = "lr_angle"
    curMan = "man"
    curMiddlebutton = "middlebutton"
    curMouse = "mouse"
    curNone = "none"
    curPencil = "pencil"
    curPirate = "pirate"
    curPlus = "plus"
    curQuestionArrow = "question_arrow"
    curRightPtr = "right_ptr"
    curRightSide = "right_side"
    curRightTee = "right_tee"
    curRightbutton = "rightbutton"
    curRtlLogo = "rtl_logo"
    curSailboat = "sailboat"
    curSbDownArrow = "sb_down_arrow"
    curSbHDoubleArrow = "sb_h_double_arrow"
    curSbLeftArrow = "sb_left_arrow"
    curSbRightArrow = "sb_right_arrow"
    curSbUpArrow = "sb_up_arrow"
    curSbVDoubleArrow = "sb_v_double_arrow"
    curShuttle = "shuttle"
    curSizing = "sizing"
    curSpider = "spider"
    curSpraycan = "spraycan"
    curStar = "star"
    curTarget = "target"
    curTcross = "tcross"
    curTopLeftArrow = "top_left_arrow"
    curTopLeftCorner = "top_left_corner"
    curTopRightCorner = "top_right_corner"
    curTopSide = "top_side"
    curTopTee = "top_tee"
    curTrek = "trek"
    curUlAngle = "ul_angle"
    curUmbrella = "umbrella"
    curUrAngle = "ur_angle"
    curWatch = "watch"
    curXterm = "xterm"

    # Windows-specific
    curwinNo = "no"
    curwinStarting = "starting"
    curwinSize = "size"
    curwinSizeNeSw = "size_ne_sw"
    curwinSizeNs = "size_ns"
    curwinSizeNwSe = "size_nw_se"
    curwinSizeWe = "size_we"
    curwinUparrow = "uparrow"
    curwinWait = "wait"

    # MacOSX-specific
    curmacCopyarrow = "copyarrow"
    curmacAliasarrow = "aliasarrow"
    curmacContextualmenuarrow = "contextualmenuarrow"
    curmacMovearrow = "movearrow"
    curmacText = "text"
    curmacCrossHair = "cross-hair"
    curmacHand = "hand"
    curmacOpenhand = "openhand"
    curmacClosedhand = "closedhand"
    curmacFist = "fist"
    curmacPointinghand = "pointinghand"
    curmacResize = "resize"
    curmacResizeleft = "resizeleft"
    curmacResizeright = "resizeright"
    curmacResizeleftright = "resizeleftright"
    curmacResizeup = "resizeup"
    curmacResizedown = "resizedown"
    curmacResizeupdown = "resizeupdown"
    curmacResizebottomleft = "resizebottomleft"
    curmacResizetopleft = "resizetopleft"
    curmacResizebottomright = "resizebottomright"
    curmacResizetopright = "resizetopright"
    curmacNotallowed = "notallowed"
    curmacPoof = "poof"
    # macWait = "wait"
    curmacCountinguphand = "countinguphand"
    curmacCountingdownhand = "countingdownhand"
    curmacCountingupanddownhand = "countingupanddownhand"
    curmacSpinning = "spinning"
    curmacHelp = "help"
    curmacBucket = "bucket"
    curmacCancel = "cancel"
    curmacEyedrop = "eyedrop"
    curmacEyedropFull = "eyedrop-full"
    curmacZoomIn = "zoom-in"
    curmacZoomOut = "zoom-out"

  AnchorPosition* = enum
    apCenter = "center"
    apNorth = "n"
    apNortheast = "ne"
    apEast = "e"
    apSoutheast = "se"
    apSouth = "s"
    apSouthwest = "sw"
    apWest = "w"
    apNorthwest = "nw"

  FillStyle* = enum
    fsNone = "none"
    fsX = "x"
    fsY = "y"
    fsBoth = "both"

  Side* = enum
    sTop = "top"
    sLeft = "left"
    sRight = "right"
    sBottom = "bottom"

  BorderMode* = enum
    bmInside = "inside"
    bmOutside = "outside"
    bmIgnore = "ignore"

  MessageBoxType* = enum
    mbtAbortRetryIgnore = "abortretryignore"
    mbtOk = "ok"
    mbtOkCancel = "okcancel"
    mbtRetryCancel = "retrycancel"
    mbtYesNo = "yesno"
    mbtYesNoCancel = "yesnocancel"

  IconImage* = enum
    iiError = "error"
    iiInfo = "info"
    iiQuestion = "question"
    iiWarning = "warning"

  ButtonName* = enum
    bnDefault = ""
    bnAbort = "abort"
    bnRetry = "retry"
    bnIgnore = "ignore"
    bnOk = "ok"
    bnCanvel = "canvel"
    bnYes = "yes"
    bnNo = "no"

  WidgetCompound* = enum
    wcNone = "none"
    wcBottom = "bottom"
    wcTop = "top"
    wcLeft = "left"
    wcRight = "right"
    wcCenter = "center"

  TextJustify* = enum
    tjLeft = "left"
    tjRight = "right"
    tjCenter = "center"

  WidgetOrientation* = enum
    woHorizontal = "horizontal"
    woVertical = "vertical"

  WidgetRelief* = enum
    wrRaised = "raised"
    wrSunken = "sunken"
    wrFlat = "flat"
    wrRidge = "ridge"
    wrSolid = "solid"
    wrGroove = "groove"

  WindowType* = enum
    wtDesktop = "desktop"
    wtDock = "dock"
    wtToolbar = "toolbar"
    wtMenu = "menu"
    wtUtility = "utility"
    wtSplash = "splash"
    wtDialog = "dialog"
    wtDropdownMenu = "dropdown_menu"
    wtPopupMenu = "popup_menu"
    wtTooltip = "tooltip"
    wtNotification = "notification"
    wtCombo = "combo"
    wtDnd = "dnd"
    wtNormal = "normal"

  FocusModel* = enum
    fmActive = "active"
    fmPassive = "passive"

  GeometryFrom* = enum
    gfUser = "user"
    gfProgram = "program"

  WindowState* = enum
    winNormal = "normal"
    winIconic = "iconic"
    winWithdrawn = "withdrawn"
    winIcon = "icon"
    winZoomed = "zoomed"

  WidgetState* = enum
    wsNormal = "normal"
    wsActive = "active"
    wsDisabled = "disabled"
    wsReadOnly = "readonly"

  AfterEventHandler* = enum
    aehIdle
    aehTimer

  VisualClass* = enum
    vcDirectcolor
    vcGrayscale
    vcPseudocolor
    vcStaticcolor
    vcStaticgray
    vcTruecolor

  ValidationMode* = enum 
    vmNone = "none"
    vmFocus = "focus"
    vmFocusin = "focusin"
    vmFocusout = "focusout"
    vmKey = "key"
    vmAll = "all"

  ActiveStyle* = enum
    asDotbox = "dotbox"
    asNone = "none"
    asUnderline = "underline"

  SelectMode* = enum
    smSingle = "single"
    smBrowse = "browse"
    smMultiple = "multiple"
    smExtended = "extended"

  ScrollbarElement* = enum
    seArrow1 = "arrow1"
    seTrough1 = "trough1"
    seSlider = "slider"
    seTrough2 = "trough2"
    seArrow2 = "arrow2"

  FontWeight* = enum
    fwNormal = "normal"
    fwBold = "bold"

  FontSlant* = enum
    fsRoman = "roman"
    fsItalic = "italic"

  MenuType* = enum
    mtMenuBar = "menubar"
    mtTearOff = "tearoff"
    mtNormal = "normal"
  
  MenuEntryType* = enum
    metCascade = "cascade"
    metCheckbutton = "checkbutton"
    metCommand = "command"
    metRadiobutton = "radiobutton"
    metSeparator = "separator"

  MenuButtonDirection* = enum
    mbdAbove = "above"
    mbdBelow = "below"
    mbdLeft = "left"
    mbdRight = "right"
    mbdFlush = "flush" # ttk

  LabelState* = enum
    lsNormal = "normal"
    lsActive = "active"
    lsDisabled = "disabled"
  
  PaneStretch* = enum  
    psAlways = "always"
    psFirst = "first"
    psLast = "last"
    psMiddle = "middle"
    psNever = "never"

  ProgressBarMode* {.pure.} = enum
    Determinate = "derminate"
    Indeterminate = "inderminate"

import ./keysyms
export keysyms
