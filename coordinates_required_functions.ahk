#Requires AutoHotkey v2.0
#SingleInstance Force

; Include active room coordinates file
#Include *i ..\Coordinates_2A.ahk
#Include *i ..\Coordinates_2B.ahk
#Include *i ..\Coordinates_2C.ahk
#Include *i ..\Coordinates_2D.ahk
#Include *i ..\Coordinates_hallway.ahk
#Include *i ..\Coordinates_office.ahk
#Include *i ..\Coordinates_acer.ahk

; ==============================================================================
; ===============CHECK OUT======================================================
; ==============================================================================
; This automates the check out sequence by clicking all the appropriate boxes in order.
; Delays are added to match the timing of the next box becoming available on ecw. 

; --------------------------------------------------------------------
; Initialize global variables 
global lastClickX := 0
global lastClickY := 0
global checkoutCancelled := false

; =============================================================
; BACKGROUND TRACKER: Memorize the last physical click coordinates
; =============================================================
~*LButton:: {
    CoordMode("Mouse", "Screen")
    global lastClickX, lastClickY
    MouseGetPos(&lastClickX, &lastClickY)
}

; =============================================================
; MACRO 1: Check-Out Flow Only (Ctrl + F1)
; =============================================================
^F1::RunCheckoutSequence(false)

; =============================================================
; MACRO 2: Check-Out AND Lock Chart (Ctrl + F2)
; =============================================================
^F2::RunCheckoutSequence(true)

; =============================================================
; SHARED WORKFLOW ENGINE
; =============================================================
RunCheckoutSequence(shouldLockChart) {
    CoordMode("Mouse", "Screen")
    global lastClickX, lastClickY, checkoutCancelled, Coords

    promptGui := ""
    progressGui := ""
    checkoutCancelled := false

    ; --- COORDINATES FETCHED FROM INCLUDED FILE ---
    clickX1  := Coords.RoomInX
    clickY1  := Coords.RoomInY
    clickX2  := Coords.OutOfRoomX
    clickY2  := Coords.OutOfRoomY
    clickX3  := Coords.SaveX
    clickY3  := Coords.SaveY
    statusX1 := Coords.StatusCaretX
    statusY1 := Coords.StatusCaretY
    statusX2 := Coords.StatusChangeX
    statusY2 := Coords.StatusChangeY
    statusX3 := Coords.StatusSelectX
    statusY3 := Coords.StatusSelectY
    ; ---------------------------------------------

    OnEscPressed(hk) {
        global checkoutCancelled
        checkoutCancelled := true
    }
    try Hotkey("*Escape", OnEscPressed, "On")

    Cleanup() {
        try Hotkey("*Escape", OnEscPressed, "Off")
        try promptGui.Destroy()
        try progressGui.Destroy()
    }

    CheckCancel() {
        global checkoutCancelled
        if (checkoutCancelled || GetKeyState("Escape", "P")) {
            checkoutCancelled := true
            Cleanup()
            ToolTip("🛑 CHECK-OUT CANCELLED 🛑")
            SetTimer(() => ToolTip(), -2000)
            return true
        }
        return false
    }

    SmartSleep(ms) {
        global checkoutCancelled
        end := A_TickCount + ms
        while (A_TickCount < end) {
            if CheckCancel()
                return false
            Sleep(20)
        }
        return true
    }

    ; ==========================================
    ; STEP 0: Reset Screen Zoom & Prompt Patient Selection
    ; ==========================================
    SendEvent("{Ctrl down}0{Ctrl up}")
    if !SmartSleep(400)
        return

    promptGui := Gui("+AlwaysOnTop +E0x20 -Caption +ToolWindow +Border")
    promptGui.BackColor := "1C2433" 
    promptGui.SetFont("s18 bold cWhite", "Segoe UI")
    promptGui.Add("Text", "Center w460 y25", "👉 CLICK BOX 👈")
    promptGui.SetFont("s13 norm cFFD700", "Segoe UI")
    promptGui.Add("Text", "Center w460 y+15", "(Press ESC to Cancel)")
    promptGui.Show("w500 h150 Center NA")

    ; Begin wait loop for user click
    Loop {
        if CheckCancel()
            return
            
        ; If physical mouse click was pressed
        if GetKeyState("LButton", "P") {
            CoordMode("Mouse", "Screen")
            MouseGetPos(&lastClickX, &lastClickY)
            
            startTime := A_TickCount
            while (A_TickCount - startTime < 600) {
                if CheckCancel()
                    return
                if GetKeyState("LButton", "P") {
                    CoordMode("Mouse", "Screen")
                    MouseGetPos(&lastClickX, &lastClickY)
                }
                Sleep(20)
            }
            break
        }
        Sleep(20)
    }

    try promptGui.Destroy()

    progressGui := Gui("+AlwaysOnTop +E0x20 -Caption +ToolWindow +Border")
    progressGui.BackColor := "1C2433" 
    progressGui.SetFont("s10 bold cWhite", "Segoe UI")
    progressGui.Add("Text", "x10 y8 w340 Center", "Auto Check-Out in Progress (ESC to Cancel)")
    progressGui.Show("w360 h35 x10 y10 NA")

    if !SmartSleep(450)
        return

    ; ==========================================
    ; STEP 1: Execute Room-Out
    ; ==========================================
    if CheckCancel()
        return

    MouseMove(clickX1, clickY1, 0)
    if !SmartSleep(150)
        return
    Click("Down")
    if !SmartSleep(100)
        return
    Click("Up")
    if !SmartSleep(400)
        return

    MouseMove(clickX2, clickY2, 0)
    if !SmartSleep(250)
        return
    Click("Down")
    if !SmartSleep(250)
        return
    Click("Up")
    if !SmartSleep(800)
        return

    MouseMove(clickX3, clickY3, 0)
    if !SmartSleep(150)
        return
    Click("Down")
    if !SmartSleep(100)
        return
    Click("Up")
    if !SmartSleep(500)
        return

    ; ==========================================
    ; STEP 2: Auto Re-Select Patient Box
    ; ==========================================
    if CheckCancel()
        return

    MouseMove(lastClickX, lastClickY, 0)
    if !SmartSleep(600)
        return

    Click("Down")
    if !SmartSleep(200)
        return
    Click("Up")
    if !SmartSleep(200)
        return
    Sleep(200)

    ; ==========================================
    ; STEP 3: Execute Check-Out Status
    ; ==========================================
    if CheckCancel()
        return

    MouseMove(statusX1, statusY1, 0)
    if !SmartSleep(150)
        return
    Click("Down")
    if !SmartSleep(150)
        return
    Click("Up")
    if !SmartSleep(400)
        return

    MouseMove(statusX2, statusY2, 0)
    if !SmartSleep(150)
        return
    Click("Down")
    if !SmartSleep(150)
        return
    Click("Up")
    if !SmartSleep(400)
        return

    MouseMove(statusX3, statusY3, 0)
    if !SmartSleep(250)
        return
    Click("Down")
    if !SmartSleep(250)
        return
    Click("Up")
    if !SmartSleep(800)
        return

    SendEvent("{Down 10}")
    if !SmartSleep(200)
        return
    SendEvent("{Enter}")
    if !SmartSleep(300)
        return
    SendEvent("{Tab}")
    if !SmartSleep(200)
        return
    SendEvent("{Enter}")

    ; ==========================================
    ; STEP 4: Lock Chart (Only if triggered by Ctrl+F2)
    ; ==========================================
    if (shouldLockChart) {
        if !SmartSleep(800)
            return

        MouseMove(lastClickX, lastClickY, 0)
        if !SmartSleep(300)
            return
        Click("Down")
        if !SmartSleep(150)
            return
        Click("Up")
        if !SmartSleep(800)
            return

        SendEvent("{Alt down}l{Alt up}")
    }

    Cleanup()
}

; =============================================================
; HELPER: Overlay Video Viewer
; =============================================================
PlayVideoOverlay(videoPath, width := 500, height := 500, displayMs := 2500) {
    if !FileExist(videoPath)
        return

    videoGui := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x20")
    videoGui.BackColor := "000000"

    wmpCtrl := videoGui.Add("ActiveX", "x0 y0 w" width " h" height, "WMPLayer.OCX")
    wmp := wmpCtrl.Value
    wmp.uiMode := "none"
    wmp.stretchToFit := true
    wmp.URL := videoPath

    posX := (A_ScreenWidth // 2) - (width // 2)
    posY := (A_ScreenHeight // 2) - (height // 2)

    videoGui.Show("x" posX " y" posY " NoActivate")
    WinSetTransColor("000000", videoGui)

    SetTimer () => videoGui.Destroy(), -displayMs
}


; ==============================================================================
; ===========================TEMPLATE LOADER====================================
; ==============================================================================
; This allows quick entry of all templates required and it will feed them one by one into the template search bar and enter into the chart. 
; It requires the template name or shorthand to be the first on the list when search quered; it will pull and enter the first on the search list. 
; Therefore, it is up to the provider to ensure their template names are optimized for quick search. 

; ==============================================================================
; CONFIGURATION
; ==============================================================================
LagDelay   := 4000  ; Milliseconds to wait between applying templates

; Global flag to signal cancellation
global AbortRequested := false

; ==============================================================================
; GLOBAL EMERGENCY ESCAPE HATCH: Escape Key
; Pressing Esc anytime will cancel the process, even during a Sleep.
; ==============================================================================
~Esc:: {
    global AbortRequested
    AbortRequested := true
}

; ==============================================================================
; HOTKEY: Ctrl + F3
; ==============================================================================
^F3:: {
    global AbortRequested
    AbortRequested := false  ; Reset cancel flag

    ; Create a quick input GUI
    queueGui := Gui("+AlwaysOnTop", "eCW Template Queue")
    queueGui.Add("Text",, "Enter shorthands (one per line or separated by commas):")
    editBox := queueGui.Add("Edit", "r5 w300 vTemplateList")
    
    btnRun := queueGui.Add("Button", "w300 Default", "Inject Templates")
    btnRun.OnEvent("Click", (*) => ProcessQueue(queueGui, editBox.Value))
    
    queueGui.Show()
}

; ==============================================================================
; QUEUE PROCESSOR & SLOTH OVERLAY
; ==============================================================================
ProcessQueue(guiObj, rawText) {
    global AbortRequested, Coords
    if Trim(rawText) == "" {
        guiObj.Destroy()
        return
    }

    guiObj.Destroy()
    templates := StrSplit(RegExReplace(rawText, "`r`n|`n|`r", ","), ",")
    CoordMode("Mouse", "Screen")

    ; --------------------------------------------------------------------------
    ; Create & Show "Template Loader in Progress" Corner Notice
    ; --------------------------------------------------------------------------
    slothGui := Gui("+AlwaysOnTop +E0x20 -Caption +ToolWindow +Border")
    slothGui.BackColor := "1C2433" 
    slothGui.SetFont("s10 bold cWhite", "Segoe UI")
    slothGui.Add("Text", "x10 y8 w340 Center", "Template Loader in Progress (ESC to Cancel)")
    slothGui.Show("w360 h35 x10 y10 NA")

    ; Reset screen magnification (Ctrl + 0)
    Send("^0")
    if SafeSleep(200) {
        slothGui.Destroy()
        return
    }

    ; --------------------------------------------------------------------------
    ; Main Loop
    ; --------------------------------------------------------------------------
    For index, item in templates {
        if (AbortRequested)
            break

        shorthand := Trim(item)
        if (shorthand == "")
            continue

        ; 1. Click template tab (fetching X/Y dynamically from Coords object)
        Click(Coords.TemplateTabX, Coords.TemplateTabY)
        if SafeSleep(300)
            break

        ; 2. Type shorthand
        Send("^a{BS}")
        if SafeSleep(100)
            break
        SendText(shorthand)
        if SafeSleep(400)
            break

        ; 3. Select top result
        Send("{Tab}{Space}")

        ; 4. Interruptible Heavy Delay
        if SafeSleep(LagDelay)
            break
    }

    ; Clean up the sloth GUI
    slothGui.Destroy()

    ; Feedback on exit
    if (AbortRequested) {
        ToolTip("⚠️ Template Injection CANCELLED!")
    } else {
        ToolTip("✅ All templates injected!")
    }
    SetTimer () => ToolTip(), -2500
}

; ==============================================================================
; HELPER: Interruptible Sleep
; Breaks long delays into 50ms chunks to check if Esc was pressed.
; ==============================================================================
SafeSleep(ms) {
    global AbortRequested
    chunks := Ceil(ms / 50)
    Loop chunks {
        if (AbortRequested)
            return true
        Sleep(50)
    }
    return AbortRequested
}

; ==============================================================================
; ===============PRESCRIPTION PRINT ENGINE/ PrintRx Function====================
; ==============================================================================
PrintRx() {
    global Coords, AbortRequested
    AbortRequested := false  ; Reset cancellation flag

    ; --- Create and Show GUI notice ---
    rxGui := Gui("+AlwaysOnTop +E0x20 -Caption +ToolWindow +Border")
    rxGui.BackColor := "1C2433" 
    rxGui.SetFont("s10 bold cWhite", "Segoe UI")
    rxGui.Add("Text", "x10 y8 w340 Center", "Printing Rx in Progress (ESC to Cancel)")
    rxGui.Show("w360 h35 x10 y10 NA")
    
    Cleanup() {
        try rxGui.Destroy()
    }
    
    CheckCancel() {
        if (AbortRequested) {
            Cleanup()
            ToolTip("⚠️ PRINT RX CANCELLED! ⚠️")
            SetTimer(() => ToolTip(), -2500)
            return true
        }
        return false
    }
    
    ; Helper to sleep and check for cancellation
    RxSleep(ms) {
        if SafeSleep(ms) {
            CheckCancel()
            return true
        }
        return false
    }

    ; --- Sequence Start ---
    SetKeyDelay 15
    SendEvent("{Tab 5}+{Space}")
    if RxSleep(400)
        return
    
    ; Reset screen magnification before clicks
    SendEvent("{Ctrl down}0{Ctrl up}")
    if RxSleep(800)
        return
    
    CoordMode("Mouse", "Screen")
    MouseMove(Coords.PrintRxX, Coords.PrintRxY, 0)
    if RxSleep(500)
        return
        
    Click("Down")
    if RxSleep(300)
        return
    Click("Up")
    
    ; Wait 10 seconds for eCW printing lag
    if RxSleep(10000)
        return
        
    Send("{Enter}")
    if RxSleep(800)
        return
        
    Send("{Esc}")
    if RxSleep(400)
        return
        
    Send("{WheelDown 3}")
    
    ; Finalize successfully
    Cleanup()
    ToolTip("✅ Rx Printed successfully!")
    SetTimer(() => ToolTip(), -2500)
}