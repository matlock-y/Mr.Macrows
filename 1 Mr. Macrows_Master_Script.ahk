; ========================================================
; Mr. Macrows: Clinical Charting
; Per specifications of Dr. Matlock Wyman (His Excellency)
; Requires AutoHotKeys v2.0.18 or later
; ========================================================

; ==============================================================================
; #region ---CODING GUIDE---
; ==============================================================================
; Preferred trigger is ";"- a 2+ letter combo is more likely to avoid collisions. Use 1 letter sparingly!
; tags with format #text#
; :*: Triggers auto send 
; :: Requires spacebar, enter, tab, period, or comma following macro to trigger send.
; MODEL :*:txt::expanded macro text

; #endregion

; ==============================================================================
; #region ---DIRECTIVES & GLOBAL SETTINGS---
; ==============================================================================
; ---Directives---
#Requires AutoHotkey v2.0.18+
#SingleInstance Force
#Warn All, OutputDebug
; --- Includes ---
#Include "CL_Master.ahk"
#Include *i ..\himitsu.ahk
#Include "coordinates_required_functions.ahk"
; #Include "AutoCap.ahk"
#Include "json-loader.ahk"
#Include "MacroMenus.ahk"
#Include *i AI_condensor.ahk
; #Include "RichEditHelper.ahk"

; Initialize Dynamic RTC Hotstrings Engine
InitDynamicRTC()
InitPastDateEngine()

; ---SHIFT + ENTER FIX---
#HotIf WinActive("ahk_exe WinProjectE.exe") ; this should only activate within ecw. 
    *$Enter::SendEvent("+{Enter}") ; enter will code for +enter (shift + Enter) $ means it will only activate if a human presses the key to avoid infinite recursion.
    *$+Enter::Send("{Enter}") ; the reverse, shift + enter will code for a normal enter in ecw just in case there needs to be an escape latch for this re-key. 
#HotIf 

; --- MACRO KILL SWITCH ---

#SuspendExempt  ; Tells AHK to NEVER suspend the hotkeys below this line
F12:: 
{
    Suspend() ; Toggles the suspension state

    if A_IsSuspended {
        ShowMacroStatus("🛑 MACROS SUSPENDED 🛑", "3B1111", "FF7B72")
    } else {
        ShowMacroStatus("✅ MACROS ACTIVE ✅", "112E1B", "7EE787")
    }
}
#SuspendExempt False ; Restores normal suspension rules for the rest of your script

ShowMacroStatus(text, bgColor := "1F2328", textColor := "FFFFFF") {
    static statusGui := ""
    
    if (statusGui != "") {
        try statusGui.Destroy()
        statusGui := ""
    }
    
    statusGui := Gui("+AlwaysOnTop -Caption +ToolWindow +Owner")
    statusGui.BackColor := bgColor
    statusGui.MarginX := 26
    statusGui.MarginY := 16
    statusGui.SetFont("s16 bold c" . textColor, "Segoe UI")
    statusGui.Add("Text", "Center", text)
    
    statusGui.Show("AutoSize Center NoActivate")
    SetTimer(() => (statusGui != "" ? (statusGui.Destroy(), statusGui := "") : 0), -2000)
}

; ---SCRIPT AUTO-RELOADER---

Global AutoReload := false

^!r::
{
    Global AutoReload
    AutoReload := !AutoReload ; Flips false to true, or true to false

    ; Show a quick pop-up so you know the status
    Status := AutoReload ? "ON" : "OFF"
    ToolTip("Auto-Reloader is now: " Status)
    SetTimer(() => ToolTip(), -2000) ; Hides the pop-up after 2 seconds
}

#HotIf WinActive(A_ScriptName)

~^s::
{
    Sleep(200)
    Reload()
}

#HotIf
; #endregion

; ==============================================================================
; Fast Paste Function; Injecting longer strings of text faster. 
; ==============================================================================

; Fast, lag-proof text injection using the clipboard
FastPaste(textToPaste) {
    ; Save existing clipboard content so you don't lose whatever you had copied
    oldClip := ClipboardAll() 
    
    ; Parse HTML and clean plain text
    htmlText := ParseTextToHTML(textToPaste)
    cleanText := GetCleanText(textToPaste)
    
    ; Set both formats to the clipboard
    SetClipboardHTML_Text(htmlText, cleanText)
    
    Send("^v") ; Instant paste
    
    Sleep(350) ; Brief buffer to let the EMR process the paste (increased to 350ms to ensure Windows/EMR reads it)
    A_Clipboard := oldClip ; Restore original clipboard
}

ParseTextToHTML(text) {
    html := text
    
    ; Convert markdown bold: **text** -> <b>text</b>
    html := RegExReplace(html, "\*\*(.*?)\*\*", "<b>$1</b>")
    
    ; Convert markdown underline: __text__ -> <u>text</u>
    html := RegExReplace(html, "__(.*?)__", "<u>$1</u>")
    
    ; Convert markdown underline: _text_ -> <u>text</u>
    html := RegExReplace(html, "_(.*?)_", "<u>$1</u>")
    
    ; Convert markdown italic: *text* -> <i>text</i>
    html := RegExReplace(html, "\*(.*?)\*", "<i>$1</i>")
    
    ; Convert newlines to HTML line breaks
    html := StrReplace(html, "`r`n", "<br>")
    html := StrReplace(html, "`n", "<br>")
    html := StrReplace(html, "`r", "<br>")
    
    return html
}

GetCleanText(text) {
    clean := text
    clean := RegExReplace(clean, "\*\*(.*?)\*\*", "$1")
    clean := RegExReplace(clean, "\*(.*?)\*", "$1")
    clean := RegExReplace(clean, "__(.*?)__", "$1")
    clean := RegExReplace(clean, "_(.*?)_", "$1")
    return clean
}

SetClipboardHTML_Text(HtmlBody, Text) {
    ; Prepare HTML boilerplate
    HtmlHeader := "Version:0.9`r`nStartHTML:00000000`r`nEndHTML:00000000`r`nStartFragment:00000000`r`nEndFragment:00000000`r`n"
    HtmlStart := "<html><body><!--StartFragment-->"
    HtmlEnd := "<!--EndFragment--></body></html>"
    
    FullHtml := HtmlHeader . HtmlStart . HtmlBody . HtmlEnd
    
    ; Compute lengths in bytes for UTF-8
    lenHeader := StrPut(HtmlHeader, "UTF-8") - 1
    lenStart := StrPut(HtmlStart, "UTF-8") - 1
    lenBody := StrPut(HtmlBody, "UTF-8") - 1
    lenEnd := StrPut(HtmlEnd, "UTF-8") - 1
    
    StartHTML := lenHeader
    StartFragment := lenHeader + lenStart
    EndFragment := StartFragment + lenBody
    EndHTML := EndFragment + lenEnd
    
    FullHtml := StrReplace(FullHtml, "00000000", Format("{:08}", StartHTML), , , 1)
    FullHtml := StrReplace(FullHtml, "00000000", Format("{:08}", EndHTML), , , 1)
    FullHtml := StrReplace(FullHtml, "00000000", Format("{:08}", StartFragment), , , 1)
    FullHtml := StrReplace(FullHtml, "00000000", Format("{:08}", EndFragment), , , 1)
    
    DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)
    DllCall("EmptyClipboard")
    
    ; 1. Set HTML Format (using UTF-8)
    bufSizeHtml := StrPut(FullHtml, "UTF-8")
    hMemHtml := DllCall("GlobalAlloc", "UInt", 0x42, "Ptr", bufSizeHtml, "Ptr")
    pMemHtml := DllCall("GlobalLock", "Ptr", hMemHtml, "Ptr")
    StrPut(FullHtml, pMemHtml, "UTF-8")
    DllCall("GlobalUnlock", "Ptr", hMemHtml)
    CF_HTML := DllCall("RegisterClipboardFormat", "Str", "HTML Format")
    DllCall("SetClipboardData", "UInt", CF_HTML, "Ptr", hMemHtml)
    
    ; 2. Set Unicode Text Format (using UTF-16)
    bufSizeText := StrPut(Text, "UTF-16")
    hMemText := DllCall("GlobalAlloc", "UInt", 0x42, "Ptr", bufSizeText, "Ptr")
    pMemText := DllCall("GlobalLock", "Ptr", hMemText, "Ptr")
    StrPut(Text, pMemText, "UTF-16")
    DllCall("GlobalUnlock", "Ptr", hMemText)
    DllCall("SetClipboardData", "UInt", 13, "Ptr", hMemText) ; 13 = CF_UNICODETEXT
    
    DllCall("CloseClipboard")
}

; ==============================================================================
; Persistent Window (RichEdit Upgrade)
; ==============================================================================

global APGui := ""
global APEdit := ""
global btnInject := "", btnCopy := "", btnClear := ""
global lastActiveHwnd := 0

; HOTKEY: Ctrl + F4 (Brings up persistent scratchpad overlay)
^F4::OpenAPScratchpad()

OpenAPScratchpad() {
    global APGui, APEdit, btnInject, btnCopy, btnClear, lastActiveHwnd
    
    ; 1. Remember active window handle
    lastActiveHwnd := WinActive("A")

    if (APGui) {
        APGui.Show()
        APEdit.Focus()
        return
    }

    ; 2. Build resizable overlay (+Resize flag)
    APGui := Gui("+AlwaysOnTop +Resize", "A&P Scratchpad")
    APGui.SetFont("s11", "Segoe UI")
    
    ; Native RichEdit control (msftedit.dll)
    APEdit := AddRichEdit(APGui, "x10 y10 w500 h250")
    
    btnInject := APGui.Add("Button", "w160 Default", "Inject to EMR (Enter)")
    btnInject.OnEvent("Click", (*) => InjectText())
    
    btnCopy := APGui.Add("Button", "w130", "Copy & Close")
    btnCopy.OnEvent("Click", (*) => CopyAndClose())

    btnClear := APGui.Add("Button", "w70", "Clear")
    btnClear.OnEvent("Click", (*) => SendMessage(0x000C, 0, StrPtr(""),, APEdit.Hwnd)) ; WM_SETTEXT

    ; Dynamic layout recalculation on window resize
    APGui.OnEvent("Size", OnGuiResize)

    ; Preserve window state when closed via 'X'
    APGui.OnEvent("Close", (*) => APGui.Hide())

    APGui.Show("w520 h350")
}

; Formatting Toggles for Hotkeys inside Scratchpad
#HotIf WinActive("A&P Scratchpad")
^b:: RichEditToggleFormat(APEdit.Hwnd, 0x1) ; Bold
^i:: RichEditToggleFormat(APEdit.Hwnd, 0x2) ; Italic
^u:: RichEditToggleFormat(APEdit.Hwnd, 0x4) ; Underline
#HotIf

; Dynamic layout recalculation on window resize
OnGuiResize(thisGui, MinMax, width, height) {
    if (MinMax = -1)
        return

    editW := Max(100, width - 20)
    editH := Max(100, height - 55)
    APEdit.Move(10, 10, editW, editH)

    btnY := height - 38
    btnInject.Move(10, btnY)
    btnCopy.Move(180, btnY)
    btnClear.Move(320, btnY)
}

; INJECT TEXT (Automated Transfer)
InjectText() {
    global APGui, APEdit, lastActiveHwnd
    
    rawText := GetRichEditText(APEdit.Hwnd)
    if (Trim(rawText) == "") {
        APGui.Hide()
        return
    }

    htmlText := ConvertTextToHTML(rawText)
    cleanText := GetCleanPlainText(rawText)

    ; Hide scratchpad first
    APGui.Hide()
    Sleep(50)

    ; Reactivate eCW window
    if (lastActiveHwnd && WinExist(lastActiveHwnd)) {
        WinActivate(lastActiveHwnd)
        Sleep(150) ; Brief pause for window focus to land
    }

    ; Format and paste
    oldClip := ClipboardAll()
    SetClipboardHTML_Text(htmlText, cleanText)
    
    Send("^v") ; Paste directly into active eCW cursor
    
    Sleep(350)
    A_Clipboard := oldClip
}

; MANUAL FALLBACK: COPY & CLOSE
CopyAndClose() {
    global APGui, APEdit
    rawText := GetRichEditText(APEdit.Hwnd)
    if (Trim(rawText) != "") {
        htmlText := ConvertTextToHTML(rawText)
        cleanText := GetCleanPlainText(rawText)
        SetClipboardHTML_Text(htmlText, cleanText)
        ToolTip("📋 Formatted text copied to clipboard!")
        SetTimer(() => ToolTip(), -1500)
    }
    APGui.Hide()
}

; ==============================================================================
; Macrow Tracker ; records how often each macro is utilized. 
; ==============================================================================
Global HotstringRegistry := Map()
Global KeyBuffer := ""

StartKeyTracker()

StartKeyTracker() {
    try {
        fileContent := FileRead(A_ScriptFullPath)
    } catch {
        return
    }
    
    Loop Parse, fileContent, "`n", "`r" {
        trimmedLine := LTrim(A_LoopField)
        ; Skip comments
        if (SubStr(trimmedLine, 1, 1) = ";")
            continue
            
        ; Match hotstrings, e.g. :*:dd;::
        if RegExMatch(trimmedLine, "^:([^:]*):([^:]+)::", &match) {
            opts := match[1]
            trigger := match[2]
            
            ; ONLY track hotstrings with the asterisk (*) auto-trigger option
            if !InStr(opts, "*")
                continue
                
            insideWord := InStr(opts, "?") > 0
            caseSensitive := InStr(opts, "C") > 0
            
            HotstringRegistry[trigger] := {
                trigger: trigger,
                inside: insideWord,
                caseSense: caseSensitive
            }
        }
    }
    
    ih := InputHook("V I1") ; V = visible, I1 = ignore keys sent by AHK script
    ih.OnChar := OnCharTyped
    ih.OnKeyDown := OnKeyDownPressed
    ih.Start()
}

OnCharTyped(ih, char) {
    Global KeyBuffer
    KeyBuffer .= char
    if (StrLen(KeyBuffer) > 100) {
        KeyBuffer := SubStr(KeyBuffer, -50) ; Keep last 50 chars to avoid memory bloat
    }
    CheckForMatches()
}

OnKeyDownPressed(ih, vk, sc) {
    Global KeyBuffer
    keyName := GetKeyName(Format("vk{:x}sc{:x}", vk, sc))
    
    if (keyName = "Backspace") {
        if (StrLen(KeyBuffer) > 0)
            KeyBuffer := SubStr(KeyBuffer, 1, -1)
    } else if (keyName = "Left" || keyName = "Right" || keyName = "Up" || keyName = "Down" || keyName = "LButton" || keyName = "RButton" || keyName = "Escape") {
        KeyBuffer := "" ; Reset buffer on navigation, mouse click, or escape
    }
}

CheckForMatches() {
    Global KeyBuffer
    
    for trigger, info in HotstringRegistry {
        triggerLen := StrLen(trigger)
        
        ; Auto-triggering hotstring (*): match must end exactly with the trigger
        bufferEnd := SubStr(KeyBuffer, -triggerLen)
        isMatch := info.caseSense ? (bufferEnd == trigger) : (bufferEnd = trigger)
        if (isMatch) {
            if (info.inside || IsWordBoundary(SubStr(KeyBuffer, 1, -triggerLen))) {
                LogTrigger(trigger)
                KeyBuffer := "" ; Reset buffer on match
                break
            }
        }
    }
}

IsWordBoundary(prevChars) {
    if (prevChars = "")
        return true ; Start of typing is a boundary
    
    lastChar := SubStr(prevChars, -1)
    
    ; Treat apostrophes and letters/numbers as inside-word characters (NOT boundaries)
    return !RegExMatch(lastChar, "^[\w']$")
}

LogTrigger(triggerName) {
    logFile := A_ScriptDir "\macro_log_" A_ComputerName ".csv"
    logLine := Format('"{1}","{2}","{3}"`n', A_Now, A_ComputerName, triggerName)
    try {
        FileAppend(logLine, logFile, "UTF-8")
    }
}

; ==============================================================================
; #region ---GENERAL USE---
; ==============================================================================

;---DATE AND TIME---
; datey-date
:*:dd;::
{
    CurrentDate := FormatTime(, "MMM d, yyyy")
    txt := "(" . CurrentDate . ")"
        Send(txt)
}
; starey-star
:*:ss;::*****

; starey-datey-date
:*:sdd;::
{
    CurrentDate := FormatTime(, "MMM d, yyyy")
    txt := "*** " . CurrentDate . " ***`n"
        Send(txt)
}
; timey-time
:*:tt;::
{ 
    Send(FormatTime(, "h:mm tt"))
}
; date-time
:*:dt;::
{
    FullStamp := FormatTime(, "MMM d, yyyy h:mm tt")
    txt := "(" . FullStamp . ")"
    Send(txt)
}

; last comprehensive exam
:*:lce;::
{
    CurrentDate := FormatTime(, "MMM d, yyyy")
    txt := "Last CE (" . CurrentDate . ")"
        Send(txt)
}

:*:bna;::
{
    SendText("==========================")
    SendEvent("{Enter}")
    SendText("BELOW NOT ADDRESSED TODAY")
    SendEvent("{Enter}")
    SendText("==========================")
}

;---Medication---
:*:x'::
{ ;enters walgreen specialty pharmacy and selects for Xdemvy Rx
    Send("wal")
    Send("{Tab}")
    Send("ric")
    Sleep(200)
    Loop 5 {
        Send("{Tab}")
        Sleep(100)
    }
    Send("{Space}")
    Sleep(100)
    Loop 23 {
        Send("{Tab}")
        Sleep(100)
    }
    Send("{Enter}")
}

;---The Meaty Stuff that Helps the Other Stuff---

SendDiagCode(heading, body, body2 :="") {
    Send("^U")
    SendText(heading)
    Send("^U")
    Sleep(300)
    SendEvent("+{Enter}")
    Sleep(300)
    SendText(body)
    if (body2 != "") {
        SendEvent("+{Enter}")
        Sleep(300)
        SendText(body2)
    }
}
; #endregion

; ==============================================================================
; Dynamic RTC Engine (AHK v2)
; ==============================================================================
; Formats single numbers (1w, 10d) and ranges (12d -> 1-2 days, 03m -> 0-3 mon)
; Trigger format: <number(s)><d/w/m/y> + Space / Enter / Tab
; Examples:
;   1w   + Space -> rtc x 1 week 
;   12w  + Space -> rtc x 1-2 weeks 
;   03m  + Space -> rtc x 0-3 mon 
;   10d  + Space -> rtc x 10 days 
;   1y   + Space -> rtc x 1 year CE
; ==============================================================================

InitDynamicRTC() {
    units := ["d", "w", "m", "y"]
    
    ; Single digits 1-9 (1d..9d, 1w..9w, 1m..9m, 1y..9y)
    loop 9 {
        num := String(A_Index)
        for u in units {
            trig := num . u
            outp := FormatRTC(num, u)
            try Hotstring("::" . trig, outp)
        }
    }
    
    ; Ranges and double digits 01-99 (01d..09d, 10d..99d)
    loop 100 {
        idx := A_Index - 1
        num := (idx < 10) ? "0" . idx : String(idx)
        for u in units {
            trig := num . u
            outp := FormatRTC(num, u)
            try Hotstring("::" . trig, outp)
        }
    }

    ; Provider follow-up shortcuts & general RTC
    try Hotstring(":*:rrmk", "rtc as scheduled c RMK")
    try Hotstring(":*:rtvn", "rtc as scheduled c TVN")
    try Hotstring(":*:rdjj", "rtc as scheduled c DJJ")
    try Hotstring(":*:rjam", "rtc as scheduled c JAM")
    try Hotstring(":*:rmw", "rtc as scheduled c MW")
    try Hotstring(":*:rww", "rtc as scheduled c WW")
    try Hotstring(":*:as;", "rtc as scheduled ")
}

FormatRTC(numRaw, unit) {
    unit := StrLower(unit)
    numFormatted := ""
    isPlural := false

    ; Determine Range vs Single Number
    if (StrLen(numRaw) == 2) {
        d1 := Integer(SubStr(numRaw, 1, 1))
        d2 := Integer(SubStr(numRaw, 2, 1))

        if (d1 == 0) {
            ; Leading zero: 01 -> 0-1, 03 -> 0-3
            numFormatted := "0-" . d2
            isPlural := true
        } else if (d1 < d2) {
            ; 2nd digit strictly greater -> Range: 12 -> 1-2, 34 -> 3-4, 68 -> 6-8
            numFormatted := d1 . "-" . d2
            isPlural := true
        } else {
            ; 2nd digit equal or smaller -> Single whole number: 10, 11, 22, 43
            numFormatted := numRaw
            isPlural := true
        }
    } else {
        ; Single digit (1-9)
        numFormatted := numRaw
        isPlural := (numRaw != "1")
    }

    ; Map Unit & Build Output
    switch unit {
        case "d":
            unitStr := isPlural ? "days" : "day"
            return Format("rtc x {} {}", numFormatted, unitStr)
        case "w":
            unitStr := isPlural ? "weeks" : "week"
            return Format("rtc x {} {}", numFormatted, unitStr)
        case "m":
            return Format("rtc x {} mon", numFormatted)
        case "y":
            unitStr := isPlural ? "years" : "year"
            return Format("rtc x {} {} CE", numFormatted, unitStr)
    }
    return ""
}

; ==============================================================================
; Dynamic Past Date Engine (AHK v2)
; ==============================================================================
; Formats past dates dynamically based on relative time inputs.
; Add InitPastDateEngine() near the top of your master script.
;
; Triggers both Shorthand AND Longhand (requires Space/Tab/Enter to trigger):
;   4ha  (or 4 hours ago)   -> 4 hours ago (7:15 AM)
;   10da (or 10 days ago)   -> 10 days ago (Aug 19, 2026)
;   2wa  (or 2 weeks ago)   -> 2 weeks ago (Aug 15, 2026)
;   3ma  (or 3 months ago)  -> 3 months ago (May 2026)
;   1ya  (or 1 year ago)    -> 1 year ago (2025)
; ==============================================================================

InitPastDateEngine() {
    units := ["h", "d", "w", "m", "y"]
    
    ; Generate triggers for 1 through 99
    loop 99 {
        num := String(A_Index)
        
        for u in units {
            outp := FormatPastDate(num, u)
            
            ; 1. Register Shorthand Triggers (e.g., ::10da)
            try Hotstring("::" . num . u . "a", outp)
            
            ; 2. Register Natural Language Triggers (e.g., ::10 days ago)
            longhand := GetLonghandTrigger(num, u)
            try Hotstring("::" . longhand, outp)
        }
    }
}

GetLonghandTrigger(num, unit) {
    isPlural := (num != "1")
    switch unit {
        case "h": return num . (isPlural ? " hours ago" : " hour ago")
        case "d": return num . (isPlural ? " days ago" : " day ago")
        case "w": return num . (isPlural ? " weeks ago" : " week ago")
        case "m": return num . (isPlural ? " months ago" : " month ago")
        case "y": return num . (isPlural ? " years ago" : " year ago")
    }
}

FormatPastDate(numRaw, unit) {
    num := Integer(numRaw)
    isPlural := (num != 1)
    stamp := A_Now
    dateSuffix := ""
    timeText := ""
    
    switch unit {
        case "h":
            timeText := num . (isPlural ? " hours ago" : " hour ago")
            stamp := DateAdd(stamp, -num, "Hours")
            dateSuffix := FormatTime(stamp, "h:mm tt")

        case "d":
            timeText := num . (isPlural ? " days ago" : " day ago")
            stamp := DateAdd(stamp, -num, "Days")
            dateSuffix := FormatTime(stamp, "MMM dd, yyyy")
            
        case "w":
            timeText := num . (isPlural ? " weeks ago" : " week ago")
            stamp := DateAdd(stamp, -(num * 7), "Days")
            dateSuffix := FormatTime(stamp, "MMM dd, yyyy")
            
        case "m":
            timeText := num . (isPlural ? " months ago" : " month ago")
            y := Integer(SubStr(stamp, 1, 4))
            m := Integer(SubStr(stamp, 5, 2))
            
            ; Calculate past month/year wrapping
            m -= num
            while (m < 1) {
                m += 12
                y -= 1
            }
            ; Pin to the 1st of the month to prevent AHK overflow errors on months missing a 31st
            newStamp := Format("{:04}{:02}01000000", y, m)
            dateSuffix := FormatTime(newStamp, "MMM yyyy")
            
        case "y":
            timeText := num . (isPlural ? " years ago" : " year ago")
            y := Integer(SubStr(stamp, 1, 4)) - num
            newStamp := Format("{:04}0101000000", y)
            dateSuffix := FormatTime(newStamp, "yyyy")
    }
    
    return timeText . " (" . dateSuffix . ")"
}

; ==============================================================================
; #region ---Technician Use---
; ==============================================================================
:*:re;:: 
{
    SetKeyDelay 15 
    SendText("Reports: `nLEE: `nGtts: ")
    Loop 2
    SendEvent("{Up}")
    Loop 5
    SendEvent("{Left}")
}

; ==============================================================================
; #region ---DIAGNOSTIC HEADERS---
; ==============================================================================

; --- Helper Functions ---
DxHeader(Label) {
    Send("^u")
    SendText(Label)
    Send("^u")
}

DxHeaderEnter(Label) {
    Send("^u")
    SendText(Label)
    Send("^u")
    Sleep 150
    Send("{Enter}")
}

; --- Formatting Shortcuts ---
:?*:uuu::
{
    if WinActive("A&P Scratchpad") {
        RichEditToggleFormat(APEdit.Hwnd, 0x4)
    } else {
        SendEvent("{Left}")
        SendEvent("+{Home}")
        Sleep(50)
        SetKeyDelay(10)
        SendEvent("^u{right}^u")
    }
}

:?*:bbb::
{
    SendEvent("+{Home}")
    Sleep(50)
    SetKeyDelay(10)
    SendEvent("^b{right}^b")
}

:?*:uubb::
{
    if WinActive("A&P Scratchpad") {
        RichEditToggleFormat(APEdit.Hwnd, 0x1)
        RichEditToggleFormat(APEdit.Hwnd, 0x4)
    } else {
        SendEvent("+{Home}")
        Sleep(50)
        SetKeyDelay(10)
        SendEvent("^b^u{right}^b^u")
    }
}

:?*:aaa::
{
    SendEvent("^a")
}
:?*://'::
{
    SendEvent("+{Home}")
    Sleep(50)
    SetKeyDelay(10)
    SendEvent("^u{right}^u{enter}")
}

; ------------------------------------------------------------------------------
; --- Refractive & Accommodative ---
; ------------------------------------------------------------------------------
:*:h;:: 
{
    DxHeaderEnter("Hyperopia")
}

:*:m;::
{
    DxHeaderEnter("Myopia")
}

:*:a;::
{
    DxHeaderEnter("Astigmatism")
}

:*:p;::
{
    DxHeaderEnter("Presbyopia")
}

; ------------------------------------------------------------------------------
; --- OSD & Anterior Segment ---
; ------------------------------------------------------------------------------
:*:ded;::
{
    DxHeaderEnter("DED")
}

:*:hor;::
{
    SendDiagCode("Hordeolum", "Use HC mask multiple times a day with digital massage towards eyelashes, taper with resolution; recom oasis brand. RTC if no resolution or worsening. ")
}

:*:chal;::
{
    SendDiagCode("Chalazion", "Use HC mask multiple times a day with digital massage towards eyelashes, taper with resolution; recom oasis brand. RTC if no resolution or worsening. ")
}

:*:sch;::
{
    SendDiagCode("Subconj Heme", "Educated pt on benign nature of condition and eventual self resolution. May use AT prn for comfort. May be caused by trauma, blood thinners or idiopathic. ")
}

:*:myo;::
{
    DxHeaderEnter("Myokymia")
    SendText("Discussed benign nature of condition and association with high stress, lack of sleep, and excess caffeine consumption. Best treated by addressing causes.")
}

:*:mcat;::
{
    SendDiagCode("CAT", "Educated pt on findings. Cataracts are not visually significant, no treatment required at this time. Continue to monitor with yearly exam.")
}

:*:pco;::
{
    SendDiagCode("PCO", "Educ pt on findings as source of decreased VA and resolution with YAG laser Tx.", "Refer to OMD for PCO/YAG eval.")
}

; ------------------------------------------------------------------------------
; --- Posterior Segment & Systemic ---
; ------------------------------------------------------------------------------
:*:nodr;::
{
    SendDiagCode("T2DM with no Ocular Complications", "Educated pt on findings. Sent communication to managing provider. Continue to monitor with yearly DFE.")
}

; #Region ---CL FIT CODES---

SendCLCode(label) {
    SendEvent("{Raw}" . label)
    Sleep(450)
    SendEvent("{Down}")
    Sleep(200)
    SendEvent("+{Enter}")
}

:*:cnst;::
{ 
    SendCLCode("CL New Fit Standard") 
}
:*:cnp;::
{
    SendCLCode("CL New Fit Premium")
}
:*:cnsp;::
{
    SendCLCode("CL New Fit Specialty")
}
:*:cust;::
{
    SendCLCode("CL Update Standard")
}
:*:cup;::
{
    SendCLCode("CL Update Premium")
}
:*:cusp;::
{
    SendCLCode("CL Update Specialty")
}
:*:crst;::
{
    SendCLCode("CL Refit Standard")
}
:*:crp;::
{
    SendCLCode("CL Refit Premium")
}
:*:crsp;::
{
    SendCLCode("CL Refit Specialty")
}

; #endregion

; ==============================================================================
; #region ---EYE EXAM DOCUMENTATION---
; ==============================================================================
SendOS(txt) { ;macros ending in ";" stay in the OD/OS side. macros ending in "(')" will enter OD and OS as well. 
    SendText(txt)
    Sleep(150)
    Loop 2 {
        Send("{Tab}")
        Sleep(100)
    }
    Send("{Space}")
}
:*:;'::
{ ;send anything from OD to OS with simple keystroke. Can also just hit tab, tab, space; but this is slightly easier. Doesn't matter where in the text string your cursor is, it will work.
    Loop 2 {
        Send("{Tab}")
        Sleep(50)    
    }
    Send("{Space}")
}

;#Hotstring EndChars -(){}:",.?!`n `t
;#Hotstring SE K5 ; consider trying #Hotstring SI T for "text" mode that presumably is faster and more reliable (?); then if ecw servers cut things off then we can do SE T K5
#Hotstring SI T
#HotString EndChars `s-:,.?!
::ck::Clear / TF adequate

::cf::Clear on NaFl / TF adequate

::tp::tr PEEs / TF adequate

::1p::
::1pees::
{
    SendText("1+ PEEs / TF inadequate")
}

::2pe::
{
    SendText("2+ PEEs / TF inadequate")
}

::3pe::
{
    SendText("3+ PEEs / TF inadequate")
}

::4pe::
{
    SendText("4+ PEEs / TF inadequate")
}

::col::
{
    SendText("(+) collarettes UL")
}
:*:col'::
{
    SendOS("(+) collarettes UL")
}
::tcol::
{
    SendText("tr collarettes UL" . A_EndChar)
}

::1col::
{
    SendText("1+ collarettes UL" . A_EndChar)
}

::2col::
{
    SendText("2+ collarettes UL" . A_EndChar)
}

::3col::
{
    SendText("3+ collarettes UL" . A_EndChar)
}

::4col::
{
    SendText("4+ collarettes UL" . A_EndChar)
}

:*:pc;::PCIOL

:*:c;::Clear

:*:pa;::
{
    SendText("(+) papillae LL palp conj")
}
:*:pa'::
{
    SendOS("(+) papillae LL palp conj")
}
::tpa::
{
    SendText("tr papillae LL palp conj" . A_EndChar)
}

::1pa::
{
    SendText("1+ papillae LL palp conj" . A_EndChar)
}

::2pa::
{
    SendText("2+ papillae LL palp conj" . A_EndChar)
}

::3pa::
{
    SendText("3+ papillae LL palp conj" . A_EndChar)
}

::4pa::
{
    SendText("4+ papillae LL palp conj" . A_EndChar)
}

::bl::
{
    SendText("(+) post bleph")
}
:*:bl'::
{
    SendOS("(+) post bleph")
}
::tbl::
{
    SendText("tr post bleph" . A_EndChar)
}

::1bl::
{
    SendText("1+ post bleph" . A_EndChar)
}

::2bl::
{
    SendText("2+ post bleph" . A_EndChar)
}

::3bl::
{
    SendText("3+ post bleph" . A_EndChar)
}

::4bl::
{
    SendText("4+ post bleph" . A_EndChar)
}

::ppvd::
{
    SendText("(+) PVD")
}
:*:ppvd'::
{
    SendOS("(+) PVD")
}
::tns::
{
    SendText("tr NS" . A_EndChar)
}

::1ns::
{
    SendText("1+ NS" . A_EndChar)
}

::2ns::
{
    SendText("2+ NS" . A_EndChar)
}

::3ns::
{
    SendText("3+ NS" . A_EndChar)
}

::4ns::
{
    SendText("4+ NS" . A_EndChar)
}

::tcs::
{
    SendText("tr CS" . A_EndChar)
}

::1cs::
{
    SendText("1+ CS" . A_EndChar)
}

::2cs::
{
    SendText("2+ CS" . A_EndChar)
}

::3cs::
{
    SendText("3+ CS" . A_EndChar)
}

::4cs::
{
    SendText("4+ CS" . A_EndChar)
}

::tpsc::
{
    SendText("tr PSC" . A_EndChar)
}

::1psc::
{
    SendText("1+ PSC" . A_EndChar)
}

::2psc::
{
    SendText("2+ PSC" . A_EndChar)
}

::3psc::
{
    SendText("3+ PSC" . A_EndChar)
}

::4psc::
{
    SendText("4+ PSC" . A_EndChar)
}

::tpco;::
{
    SendText("tr PCO" . A_EndChar)
}

::1pco::
{
    SendText("1+ PCO" . A_EndChar)
}

::2pco::
{
    SendText("2+ PCO" . A_EndChar)
}

::3pco::
{
    SendText("3+ PCO" . A_EndChar)
}

::4pco::
{
    SendText("4+ PCO" . A_EndChar)
}

::pcell::
{
    SendText("(+) cell" . A_EndChar)
}
:*:pcell'::
{
    SendOS("(+) cell")
}
::tcell::
{
    SendText("tr cell" . A_EndChar)
}

::1cell::
{
    SendText("1+ cell" . A_EndChar)
}

::2cell::
{
    SendText("2+ cell" . A_EndChar)
}

::3cell::
{
    SendText("3+ cell" . A_EndChar)
}

::4cell::
{
    SendText("4+ cell" . A_EndChar)
}

:*:nrfq;::
{
    SendText("no breaks, RD, or pathology 360 on 4 quadrant views.")
}

:*:fq;::
{
    SendText("on 4 quadrant views.")
}

:*:nr;::no breaks, RD, or pathology 360

; #endregion

