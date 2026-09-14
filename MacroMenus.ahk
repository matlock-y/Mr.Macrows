#Requires AutoHotkey v2.0

; ==============================================================================
; ====   Menu Macros   ===
; ==============================================================================

; #region ==== CL fit Menu Macro =====

;--CL Fit Global State--
Global Fit_Status := "" 
Global Fit_Type := ""
Global CL_Brand := ""
Global OR_Changes := ""
Global CL_Plan := ""
Global Hygiene := ""
Global Has_OR_Changes := false
Global Horiz := 0
Global Vert := 0

;--Vision and Comfort Menu--
ComfortMenu := Menu()
ComfortMenu.Add("&a - Good comfort and vision with", SetFit_Status)
ComfortMenu.Add("&s - Good comfort and poor distance vision with", SetFit_Status)
ComfortMenu.Add("&d - Good comfort and poor near vision", SetFit_Status)
ComfortMenu.Add("&f - Poor comfort with", SetFit_Status)

;--Fit Type Menu--
FitMenu := Menu()
FitMenu.Add("&a - existing wear of", SetFit_Type)
FitMenu.Add("&s - trial of", SetFit_Type)
FitMenu.Add("&d - refit into", SetFit_Type)
FitMenu.Add("&f - new fit into", SetFit_Type)

;--OR Menu--
ORMenu := Menu()
ORMenu.Add("Current Trial OR Change?", SetOR_Changes)
ORMenu.Disable("Current Trial OR Change?")
ORMenu.Add()
ORMenu.Add("&a - No OR changes", SetOR_Changes)
ORMenu.Add("&s - with OR changes OD", SetOR_Changes)
ORMenu.Add("&d - with OR changes OS", SetOR_Changes)
ORMenu.Add("&f - with OR changes OU", SetOR_Changes)

;--Trial Menu--
CL_TrialMenu := Menu()
CL_TrialMenu.Add("CL Trials?", SetDispense_Trials)
CL_TrialMenu.Disable("CL Trials?")
CL_TrialMenu.Add()
CL_TrialMenu.Add("&a - no trials", SetDispense_Trials)
CL_TrialMenu.Add("&s - dispense trials", SetDispense_Trials)
CL_TrialMenu.Add("&d - dispense trials with OR changes", SetDispense_Trials)
CL_TrialMenu.Add("&f - dispense trials without OR changes", SetDispense_Trials)
CL_TrialMenu.Add("&g - order trials with OR changes", SetDispense_Trials)

;--Order Trials Menu--
CL_OrderTrialsMenu := Menu()
CL_OrderTrialsMenu.Add("Order Trials Options", SetOrderTrials_Option)
CL_OrderTrialsMenu.Disable("Order Trials Options")
CL_OrderTrialsMenu.Add()
CL_OrderTrialsMenu.Add("&a - rtc, dr visit", SetOrderTrials_Option)
CL_OrderTrialsMenu.Add("&s - dispense, no visit", SetOrderTrials_Option)


;--Hygiene Menu--
CL_HygieneMenu := Menu()
CL_HygieneMenu.Add("Discussed Hygiene for-", SetHygiene)
CL_HygieneMenu.Disable("Discussed Hygiene for-")
CL_HygieneMenu.Add()
CL_HygieneMenu.Add("&a - daily", SetHygiene)
CL_HygieneMenu.Add("&s - weekly", SetHygiene)
CL_HygieneMenu.Add("&d - biweekly", SetHygiene)
CL_HygieneMenu.Add("&f - monthly", SetHygiene)
CL_HygieneMenu.Add("&g - weekly EW", SetHygiene)
CL_HygieneMenu.Add("&h - monthly EW", SetHygiene)
CL_HygieneMenu.Add("&j - skip", SetHygiene)


;--- Finalize CL Macro Menu ---
:*:cl;::
{
    Global Horiz, Vert, Fit_Status, Fit_Type, CL_Brand, OR_Changes, CL_Plan, Hygiene, Has_OR_Changes

    Fit_Status := "" 
    CL_Brand := ""
    Fit_Type := ""
    OR_Changes := ""
    CL_Plan := ""
    Hygiene := ""
    Has_OR_Changes := false

    WinGetPos(&X, &Y, &W, &H, "A")
    Horiz := W / 2
    Vert := H / 4
    SetTimer(() => ComfortMenu.Show(Horiz, Vert), -10)
}

SetFit_Status(ItemName, ItemPos, MyMenu)
{
    Global Fit_Status, Horiz, Vert
    Fit_Status := RegExReplace(ItemName, "^&. - ")
    FitMenu.Show(Horiz, Vert)
}

SetFit_Type(ItemName, ItemPos, MyMenu)
{
    Global Fit_Type, Horiz, Vert
    Fit_Type := RegExReplace(ItemName, "^&. - ")
    GetCL_Brand()
}

GetCL_Brand()
{
    Global CL_Brand, Horiz, Vert

    userBox := InputBox("Type the CL Brand (or use your macro):", "Lens Selection", "W300 H130")

    if (userBox.Result = "Cancel") {
        return 
    }

    ; Strip any accidental trailing punctuation so it flows cleanly into OR notes
    CL_Brand := RTrim(Trim(userBox.Value), ".?!")

    ORMenu.Show(Horiz, Vert) 
}

SetOR_Changes(ItemName, ItemPos, MyMenu)
{
    Global OR_Changes, Has_OR_Changes, Horiz, Vert

    if (ItemName = "&a - No OR changes")
    {
        OR_Changes := "."
        Has_OR_Changes := false
    }
    else
    {
        changesText := RegExReplace(ItemName, "^&. - ")
        OR_Changes := " " . changesText . "."
        Has_OR_Changes := true
    }
    CL_TrialMenu.Show(Horiz, Vert)
}

SetDispense_Trials(ItemName, ItemPos, MyMenu)
{
    Global CL_Plan, Has_OR_Changes, Horiz, Vert
    
    if (ItemName = "&a - no trials")
    {
        CL_Plan := Has_OR_Changes ? "Finalize CL Rx with OR changes." : "Finalize CL Rx."
        CL_HygieneMenu.Show(Horiz, Vert)
    }
    else if InStr(ItemName, "order trials")
    {
        CL_OrderTrialsMenu.Show(Horiz, Vert)
    }
    else
    {
        trialAction := RegExReplace(ItemName, "^&. - ")
        trialAction := RTrim(trialAction, ".")
        CL_Plan := "Finalize CL Rx and " . trialAction . ". Pt may trial ahead of ordering."
        CL_HygieneMenu.Show(Horiz, Vert)
    }
}

SetOrderTrials_Option(ItemName, ItemPos, MyMenu)
{
    Global CL_Plan, Has_OR_Changes, Horiz, Vert

    prefix := Has_OR_Changes ? "Finalize CL Rx with OR changes." : "Finalize CL Rx."

    if (ItemName = "&a - rtc, dr visit")
    {
        CL_Plan := prefix . "`norder trials, rtc with dr visit when trials arrive."
    }
    else if (ItemName = "&s - dispense, no visit")
    {
        CL_Plan := prefix . "`norder trials, dispense trials withOUT dr visit when trials arrive."
    }

    CL_HygieneMenu.Show(Horiz, Vert)
}


SetHygiene(ItemName, ItemPos, MyMenu)
{
    Global Hygiene
    switch ItemPos
    {
        case 3: ; daily
            Hygiene := " `nReviewed daily replacement, no sleeping or water activities in CL."
        case 4: ; weekly
            Hygiene := " `nReviewed weekly replacement, no sleeping or water activities in CL."
        case 5: ; biweekly
            Hygiene := " `nReviewed bi-weekly replacement, no sleeping or water activities in CL."
        case 6: ; monthly
            Hygiene := " `nReviewed monthly replacement, no sleeping or water activities in CL."
        case 7: ; weekly EW
            Hygiene := " `nReviewed weekly replacement, CL are approved for 1 week EW, but I recom removing before sleep; no water activities in CL."
        case 8: ; monthly EW
            Hygiene := " `nReviewed monthly replacement, CL are approved for 1 mon EW, but I recom removing before sleep; no water activities in CL."
        case 9: ; skip
            Hygiene := ""
    }
    FinishFit()
}

FinishFit()
{
    Global Fit_Status, Fit_Type, CL_Brand, OR_Changes, CL_Plan, Hygiene
    SendText(Fit_Status . " " . Fit_Type . " " . CL_Brand . OR_Changes . " " . CL_Plan . Hygiene)
}
; #endregion

; ===================================================
; ================== Big DM Macro ===================
; ===================================================
; #region 
;--DM Global State--
Global DR_Stage := "" ;memory variable for each peice of the Dx
Global DR_Laterality := ""
Global DME_Presence := ""
Global DME_Laterality := ""
Global Horiz := 0
Global Vert := 0

;--DM Menu--
DMMenu := Menu()
DMMenu.Add("&a - No DR", InsertNoDR)
DMMenu.Add("&s - Mild DR", SetDR_Stage)
DMMenu.Add("&d - Moderate DR", SetDR_Stage)
DMMenu.Add("&f - Severe DR", SetDR_Stage)
DMMenu.Add("&g - Proliferative DR", SetDR_Stage)

;--DR Laterality Menu--
DR_LatMenu := Menu()
DR_LatMenu.Add("&a - OD", SetDR_Laterality)
DR_LatMenu.Add("&s - OS", SetDR_Laterality)
DR_LatMenu.Add("&d - OU", SetDR_Laterality)

;--DME Menu--
DMEMenu := Menu()
DMEMenu.Add("&a - (-)DME", SetDME_Presence)
DMEMenu.Add("&s - (+)DME", SetDME_Presence)

;--DME Laterality Menu--
DME_LatMenu := Menu()
DME_LatMenu.Add("&a - OD", SetDME_Laterality)
DME_LatMenu.Add("&s - OS", SetDME_Laterality)
DME_LatMenu.Add("&d - OU", SetDME_Laterality)

:b0*:dm;::
{
    Global Horiz, Vert, DR_Stage, DR_Laterality, DME_Presence, DME_Laterality

    SetKeyDelay 15 ; need to build in keydelay with manual backspace rather than automatic backspace b/c ecw lol. 
    SendEvent("{Backspace 3}")

    DR_Stage := "" ;wipe all buckets clean so there is not data from last run leftover. 
    DR_Laterality := ""
    DME_Presence := ""
    DME_Laterality := ""

    CoordMode("Menu", "Window")
    WinGetPos(&X, &Y, &W, &H, "A")
    Horiz := W / 2
    Vert := H / 4
    SetTimer(() => DMMenu.Show(Horiz, Vert), -10)
}
InsertNoDR(ItemName, ItemPos, MyMenu)
{
    SendDiagCode("T2DM with no Ocular Complications", "Educated pt on findings. Sent communication to managing provider.", "Continue to monitor with yearly DFE.")
}
SetDR_Stage(ItemName, ItemPos, MyMenu)
{
    Global DR_Stage, Horiz, Vert
    DR_Stage := RegExReplace(ItemName, "^&. - ")
    DR_LatMenu.Show(Horiz, Vert)
}
SetDR_Laterality(ItemName, ItemPos, MyMenu)
{
    Global DR_Laterality, Horiz, Vert
        DR_Laterality := RegExReplace(ItemName, "^&. - ")
        DMEMenu.Show(Horiz, Vert)
}


SetDME_Presence(ItemName, ItemPos, MyMenu)
{
    Global DME_Presence, DME_Laterality, Horiz, Vert
        DME_Presence := RegExReplace(ItemName, "^&. - ")
        if (DME_Presence = "(-)DME") { ;if (-)DME is selected then assign "" (nothing) to DME Laterality and skip straight to FinishDR function. 
            DME_Laterality := ""
            FinishDR()
        }
        else {
        DME_LatMenu.Show(Horiz, Vert)   
        }

}
SetDME_Laterality(ItemName, ItemPos, MyMenu)
{
    Global DME_Laterality
        DME_Laterality := RegExReplace(ItemName, "^&. - ")
        FinishDR()
}
FinishDR()
{
    Global DR_Stage, DR_Laterality, DME_Presence, DME_Laterality
    h := DR_Stage . " " . DR_Laterality . " " . DME_Presence 
    if (DME_Laterality != "") {
        h := h . " " . DME_Laterality
    }
    b := "Educated pt on findings. Sent communication to managing provider. BG control encouraged to prevent worsening/aid in reversal."
    b2 := ""
    if (InStr(DME_Presence, "(+)")){
        b2 := "Refer to retina specialist for management x na."
    }
    else {
        b2 := "Continue to monitor with yearly DFE."
    }
    SendDiagCode(h, b, b2)
}
; #endregion

; ==============================================================================
;        --- IMAGING INTERPRETATION ENGINE ---
; ==============================================================================
; #region
; --- 1. GLOBAL STATE ---
Global Img_Test := "", Img_Ind := "", Img_Find := "", Img_Qual := "", Img_Comp := ""
Global Img_H := 0, Img_V := 0

; --- 2. MAIN MENU DEFINITION ---
ImagingMenu := Menu()
ImagingMenu.Add("&a - rOCT", StartImaging)
ImagingMenu.Add("&s - gOCT", StartImaging)
ImagingMenu.Add("&d - VF", StartImaging)
ImagingMenu.Add("&f - Fundus Photos", StartImaging)
ImagingMenu.Add("&g - K topo", StartImaging)
ImagingMenu.Add("&h - IOL Master", StartImaging)

; --- 3. THE TRIGGER ---
:*:ii;::
{
    Global Img_H, Img_V
    WinGetPos(&X, &Y, &W, &H, "A")
    Img_H := W / 2, Img_V := H / 4
    SetTimer(() => ImagingMenu.Show(Img_H, Img_V), -10)
}

; --- 4. ENGINE START ---
StartImaging(ItemName, *) {
    Global Img_Test, Img_Ind, Img_Find, Img_Qual, Img_Comp
    Img_Test := RegExReplace(ItemName, "^&. - ")
    Img_Ind := "", Img_Find := "", Img_Qual := "", Img_Comp := ""
    ShowIndMenu()
}

; --- 5. DYNAMIC MENU BUILDERS ---

ShowIndMenu() {
    Global Img_Test, Img_H, Img_V
    m := Menu(), m.Add("Indications:", (*) => ""), m.Disable("Indications:"), m.Add()

    opts := []
    switch Img_Test {
        case "rOCT":          opts := ["drusen", "RPE mottling", "AMD", "Mac Edema", "Retinopathy", "Reduced VA"]
        case "gOCT":          opts := ["glc suspect", "glc", "ONH anomalies"]
        case "VF":            opts := ["glc suspect", "glc", "VF defect"]
        case "K topo":        opts := ["K conus suspect", "VA loss"]
        case "Fundus Photos": opts := ["Pt opts in lieu of dilation"]
        case "IOL Master":    opts := ["Myopia management", "CAT eval"]
    }

    homeRow := ["a", "s", "d", "f", "g", "h"]
    for i, opt in opts
        m.Add("&" . homeRow[i] . " - " . opt, HandleInd)

    m.Add("&z - Free type", HandleInd)
    m.Show(Img_H, Img_V)
}

HandleInd(ItemName, *) {
    Global Img_Ind, Img_Test
    val := RegExReplace(ItemName, "^&. - ")
    if (val = "Free type") {
        ib := InputBox("Type Indications:", Img_Test, "W300 H130")
        if (ib.Result == "Cancel") {
            return
        }
        Img_Ind := Trim(ib.Value)
    } else {
        Img_Ind := val
    }
    ShowFindMenu()
}

ShowFindMenu() {
    Global Img_Test, Img_H, Img_V
    m := Menu(), m.Add("Findings:", (*) => ""), m.Disable("Findings:"), m.Add()

    opts := []
    switch Img_Test {
        case "rOCT":          opts := ["(-) Anomalies", "Drusen", "Edema", "Documented on rOCT"]
        case "gOCT":          opts := ["Robust RNFL 360 OU", "RNFL Thinning", "Swollen RNFL", "Findings documented"]
        case "VF":            opts := ["Clean field", "Defects noted"]
        case "K topo":        opts := ["Normal topo pattern OU", "K-conus", "Pellucid Marginal Degeneration"]
        case "Fundus Photos": opts := ["(-) Anomalies OU", "Findings Documented in photos"]
        case "IOL Master":    opts := ["A-Scan Documented", "Findings Documented"]
    }

    homeRow := ["a", "s", "d", "f", "g", "h"]
    for i, opt in opts
        m.Add("&" . homeRow[i] . " - " . opt, HandleFind)

    m.Add("&z - Free type", HandleFind)
    m.Show(Img_H, Img_V)
}

HandleFind(ItemName, *) {
    Global Img_Find, Img_Test
    val := RegExReplace(ItemName, "^&. - ")
    if (val = "Free type") {
        ib := InputBox("Type Findings:", Img_Test, "W300 H130")
        if (ib.Result == "Cancel") {
            return
        }
        Img_Find := Trim(ib.Value)
    } else {
        Img_Find := val
    }
    ShowQualMenu()
}

ShowQualMenu() {
    Global Img_Test, Img_H, Img_V
    m := Menu(), m.Add("Quality:", (*) => ""), m.Disable("Quality:"), m.Add()

    if (Img_Test = "VF") {
        m.Add("&a - Reliable", HandleQual)
        m.Add("&s - Questionable reliability", HandleQual)
        m.Add("&d - Unreliable", HandleQual)
    } else {
        m.Add("&a - High", HandleQual)
        m.Add("&s - Moderate", HandleQual)
        m.Add("&d - Poor", HandleQual)
    }
    m.Show(Img_H, Img_V)
}

HandleQual(ItemName, *) {
    Global Img_Qual
    Img_Qual := RegExReplace(ItemName, "^&. - ")
    ShowCompMenu()
}

ShowCompMenu() {
    Global Img_H, Img_V
    m := Menu(), m.Add("Comparison:", (*) => ""), m.Disable("Comparison:"), m.Add()

    m.Add("&a - None, baseline", FinishImaging)
    m.Add("&s - Stable to baseline", FinishImaging)
    m.Add("&d - Worsen compared to baseline", FinishImaging)
    m.Add("&f - Improved compared to baseline", FinishImaging)
    m.Add("&z - Free type", FinishImaging)
    m.Show(Img_H, Img_V)
}
; --- 6. FINAL EXECUTION ---
FinishImaging(ItemName, *) {
    Global Img_Comp, Img_Test, Img_Ind, Img_Find, Img_Qual
    val := RegExReplace(ItemName, "^&. - ")

    if (val = "Free type") {
        ib := InputBox("Type Comparison:", Img_Test, "W300 H130")
        if (ib.Result == "Cancel") {
            return
       }
        Img_Comp := Trim(ib.Value)
    } else {
        Img_Comp := val
    }

    currentDate := FormatTime(, "MMM, dd, yyyy")

    SetKeyDelay(10) 

    ; Sending text and commands separately is most reliable for ECW
    SendEvent("{Text}" . Img_Test . " (" . currentDate . ")")
    SendEvent("+{Enter}")

    SendEvent("{Text}Indications: " . Img_Ind)
    SendEvent("+{Enter}")

    SendEvent("{Text}Findings: " . Img_Find)
    SendEvent("+{Enter}")

    SendEvent("{Text}Quality: " . Img_Qual)
    SendEvent("+{Enter}")

    SendEvent("{Text}Comparison: " . Img_Comp)
    SendEvent("+{Enter}")

    ; Final release to ensure Shift isn't stuck
    SendEvent("{Shift Up}")
}

; #endregion

; =========================================
;       --- Demodex Menu Macro ---
; =========================================
; #region
; --- 1. THE DEMODEX TRIGGER & GUI ---
:*:dem;::
{
    ; Create the Custom Checkbox Window
    demGui := Gui("-MinimizeBox -MaximizeBox +AlwaysOnTop", "Select Demodex Symptoms")

    ; Add the Checkboxes with visual labels
    demGui.Add("Checkbox", "vItchy", "(a) Itchy")
    demGui.Add("Checkbox", "vWatery", "(s) Watery")
    demGui.Add("Checkbox", "vGritty", "(d) Gritty")
    demGui.Add("Checkbox", "vCrust", "(g) AM Crust")
    demGui.Add("Checkbox", "vBlurry", "(j) Blurry VA")
    demGui.Add("Checkbox", "vStyes", "(k) Styes (Hordeolum/ Chalazion)")
    demGui.Add("Checkbox", "vAsymptomatic", "(q) Asymptomatic")

    ; Add custom symptom free-type box
    demGui.Add("Text",, "(z) Custom Symptom:")
    demGui.Add("Edit", "vCustomSymptom w200")

    ; Add the Submit Button
    btn := demGui.Add("Button", "w150 Default", "Submit")
    btn.OnEvent("Click", ProcessDemSymptoms)

    ; The Escape Hatch
    demGui.OnEvent("Escape", (GuiObj) => GuiObj.Destroy())

    ; Show the window on screen
    SetTimer(() => demGui.Show(), -10)
}

; --- 2. THE GRAMMATICAL ENGINE ---
ProcessDemSymptoms(BtnObj, Info)
{
    ; Save which boxes were checked and hide the window
    saved := BtnObj.Gui.Submit() 

    BtnObj.Gui.Destroy() ;destroy menu immediately to prevent issues with crashing afterwards. 
    ; =========================================
    ; ASYMPTOMATIC PATH (Overrides everything)
    ; =========================================
    if (saved.Asymptomatic) {
        ; Creates a pop-up menu at the cursor
        TxMenu := Menu()
        TxMenu.Add("Pt opts to:", (*) => "")
        TxMenu.Disable("Pt opts to:") ; Greys out the header
        TxMenu.Add()
        TxMenu.Add("&a - Tx", HandleDemTx)
        TxMenu.Add("&s - No Tx", HandleDemTx)
        TxMenu.Show()
        return ; Stops the script here so it doesn't run the symptomatic code below
    }

    ; =========================================
    ; SYMPTOMATIC PATH 
    ; =========================================
    ; Put the checked adjectives into a temporary list
    adjList := []
    if saved.Itchy
        adjList.Push("itchy")
    if saved.Watery
        adjList.Push("watery")
    if saved.Gritty
        adjList.Push("gritty")

    sympStr := ""

    ; Assemble the adjectives with JUST commas
    if (adjList.Length > 0) {
        for index, adj in adjList {
            if (index == 1) {
                sympStr .= adj
            } else {
                sympStr .= ", " . adj
            }
        }
        sympStr .= " eyes"
    }

    ; Put other checked symptoms in a separate list to join nicely
    otherList := []
    if saved.Crust
        otherList.Push("AM crust")
    if saved.Blurry
        otherList.Push("blurry VA")
    if saved.Styes
        otherList.Push("styes (hordeolum/chalazion)")
    if (saved.CustomSymptom != "") {
        otherList.Push(Trim(saved.CustomSymptom))
    }

    finalSympStr := ""
    if (otherList.Length > 0) {
        otherStr := ""
        for index, item in otherList {
            if (index == 1) {
                otherStr := item
            } else if (index == otherList.Length) {
                otherStr .= " and " . item
            } else {
                otherStr .= ", " . item
            }
        }

        if (sympStr != "") {
            finalSympStr := sympStr . " and " . otherStr
        } else {
            finalSympStr := otherStr
        }
    } else {
        finalSympStr := sympStr
    }

    ; Fallback if you accidentally hit enter with nothing checked
    if (finalSympStr == "") {
        finalSympStr := "unspecified symptoms"
    }

    ; Construct the final clinical string
    finalText := "Educ pt on findings as source of symptoms of " . finalSympStr . ". Start Xdemvy 1 gt BID OU x until bottle is empty (at least 6 weeks). Rx sent to Walgreens specialty in Richmond, mail order. Expect cost to be max $50 when savings program is applied, expect to give ss # for savings program. Contact clinic if any issues obtaining gt."

    ; Pass the baton to your existing function!
    SendDiagCode("Demodex", finalText)
}

; --- 2B. THE ASYMPTOMATIC MENU HANDLER ---
HandleDemTx(ItemName, ItemPos, MyMenu)
{
    if (ItemName = "&a - Tx") {
        finalText := "Educ pt on findings as potential source of future symptoms. Pt opts to initiate Tx. Start Xdemvy 1 gt BID OU x until bottle is empty (at least 6 weeks). Rx sent to Walgreens specialty in Richmond, mail order. Expect cost to be max $50 when savings program is applied, expect to give ss # for savings program. Contact clinic if any issues obtaining gt."
    } else {
        finalText := "Pt asymptomatic, opts for monitoring at this time."
    }

    SendDiagCode("Demodex", finalText)
}

; This block ONLY hijacks these keys when the "Select Demodex Symptoms" window is active and Edit is not focused
#HotIf WinActive("Select Demodex Symptoms") && ActiveCtrlIsNotEdit("Select Demodex Symptoms")
a::ControlClick("Button1", "Select Demodex Symptoms")
s::ControlClick("Button2", "Select Demodex Symptoms")
d::ControlClick("Button3", "Select Demodex Symptoms")
g::ControlClick("Button4", "Select Demodex Symptoms")
j::ControlClick("Button5", "Select Demodex Symptoms")
k::ControlClick("Button6", "Select Demodex Symptoms")
q::ControlClick("Button7", "Select Demodex Symptoms")
z::ControlFocus("Edit1", "Select Demodex Symptoms")
#HotIf
; #endregion

; =================================================
;          ---Allergic Conj Menu Macro ---
; =================================================
; #region
; --- 1. THE TRIGGER & GUI 1 (Symptoms) ---
:*:ac;::
{
    ; Create the Custom Checkbox Window
    acGui := Gui("-MinimizeBox -MaximizeBox +AlwaysOnTop", "Select Symptoms")

    ; Add the Checkboxes with visual labels
    acGui.Add("Checkbox", "vItchy", "(a) Itchy")
    acGui.Add("Checkbox", "vWatery", "(s) Watery")
    acGui.Add("Checkbox", "vGritty", "(d) Gritty")
    acGui.Add("Checkbox", "vRed", "(f) Red")
    acGui.Add("Checkbox", "vBlurry", "(g) Blurry VA")
    acGui.Add("Checkbox", "vPainful", "(h) Painful")

    ; Add the Submit Button ("Default" means hitting 'Enter' clicks it automatically!)
    btn := acGui.Add("Button", "w150 Default", "Submit")
    btn.OnEvent("Click", ProcessSymptoms)

    ; The Escape Hatch
    acGui.OnEvent("Escape", (GuiObj) => GuiObj.Destroy())

    ; Show the window on screen
    SetTimer(() => acGui.Show(), -10)
}

; --- 2. THE GRAMMATICAL ENGINE & NOTES ---
ProcessSymptoms(BtnObj, Info)
{
    ; This saves which boxes were checked and hides the window
    saved := BtnObj.Gui.Submit() 

    ; Put the checked adjectives into a temporary list
    adjList := []
    if saved.Itchy
        adjList.Push("itchy")
    if saved.Watery
        adjList.Push("watery")
    if saved.Gritty
        adjList.Push("gritty")
    if saved.Red
        adjList.Push("red")
    if saved.Painful
        adjList.Push("painful")

    sympStr := ""

    ; Assemble the adjectives with JUST commas (no 'and')
    if (adjList.Length > 0) {
        for index, adj in adjList {
            if (index == 1) {
                sympStr .= adj
            } else {
                sympStr .= ", " . adj
            }
        }
        sympStr .= " eyes"
    }

    ; Tack on Blurry VA to the end if selected
    if (saved.Blurry) {
        if (sympStr != "") {
            sympStr .= " and blurry VA"
        } else {
            sympStr := "blurry VA"
        }
    }

    ; Fallback if you accidentally hit enter with nothing checked
    if (sympStr == "") {
        sympStr := "unspecified symptoms"
    }

    ; Construct the final clinical string
    finalText := "Pt is symptomatic of " . sympStr . " with clinical signs of papillae OU."

    ; Prompt for additional notes IMMEDIATELY after symptoms
    ib := InputBox("Additional notes:", "AC Additional", "W300 H120")
    if (ib.Result = "OK" && Trim(ib.Value) != "") {
        notesText := Trim(ib.Value)
        lastChar := SubStr(notesText, -1)
        if (lastChar != "." && lastChar != "?" && lastChar != "!") {
            notesText .= "."
        }
        finalText .= " " . notesText
    }

    ; Launch GUI 2 for treatment, passing the combined text forward
    ShowTreatmentGui(finalText)
}

; --- 3. GUI 2 (Treatment) ---
ShowTreatmentGui(symptomText)
{
    txGui := Gui("-MinimizeBox -MaximizeBox +AlwaysOnTop", "Select Treatment")

    ; Add Radio buttons (grouping automatically handles mutual exclusivity)
    txGui.Add("Radio", "vTxChoice Checked1", "(a) OTC gt")
    txGui.Add("Radio", "", "(s) FML")
    txGui.Add("Radio", "", "(d) Pred Acetate")

    btn := txGui.Add("Button", "w150 Default", "Submit")
    
    ; Pass the symptom string forward via fat arrow function
    btn.OnEvent("Click", (BtnObj, Info) => ProcessTreatment(BtnObj, symptomText))

    txGui.OnEvent("Escape", (GuiObj) => GuiObj.Destroy())
    txGui.Show()
}

ProcessTreatment(BtnObj, symptomText)
{
    ; Save TxChoice (returns 1, 2, or 3 based on radio selected)
    saved := BtnObj.Gui.Submit() 
    txPlan := ""

    if (saved.TxChoice == 1) {
        txPlan := "Use Lastacaft or Pataday XS 1 gt OU QDAY until resolution, then prn. "
    } else if (saved.TxChoice == 2) {
        txPlan := "Rx FML 1 gt OU 1-3x/day as needed."
    } else if (saved.TxChoice == 3) {
        txPlan := "Rx Pred Acetate 1 gt OU 2-3x/day x 1-3 weeks; then use otc allergy gt QDAY to prn."
    }

    ; Pass the baton to your existing function!
    SendDiagCode("Allergic Conj", symptomText, txPlan)
}

; --- 4. THE SINGLE-KEYSTROKE INTERCEPTORS ---
; Hijack keys for Symptoms window
#HotIf WinActive("Select Symptoms")
a::ControlClick("Button1", "Select Symptoms")
s::ControlClick("Button2", "Select Symptoms")
d::ControlClick("Button3", "Select Symptoms")
f::ControlClick("Button4", "Select Symptoms")
g::ControlClick("Button5", "Select Symptoms")
h::ControlClick("Button6", "Select Symptoms")

; Hijack keys for Treatment window
#HotIf WinActive("Select Treatment")
a::ControlClick("Button1", "Select Treatment")
s::ControlClick("Button2", "Select Treatment")
d::ControlClick("Button3", "Select Treatment")

#HotIf
; #endregion


; ============================================
;           Cataract Macro Menu (Meow)
; ============================================
; #region --- Cataract Menu Macro ---
;--CAT Global State--
Global CAT_Severity := ""
Global CAT_Laterality := ""
Global CAT_Procedure := ""
Global Horiz := 0
Global Vert := 0

;--CAT Menu--
CATMenu := Menu()
CATMenu.Add("&a - Mild, not VS", InsertMCAT)
CATMenu.Add("&s - Becoming VS", SetCAT_Severity)
CATMenu.Add("&d - VS", SetCAT_Severity)

;--CAT Laterality Menu--
CAT_LatMenu := Menu()
CAT_LatMenu.Add("&a - OD", SetCAT_Laterality)
CAT_LatMenu.Add("&s - OS", SetCAT_Laterality)
CAT_LatMenu.Add("&d - OU", SetCAT_Laterality)

;--CAT Procedure Menu--
CAT_ProcMenu := Menu()
CAT_ProcMenu.Add("&a - Sx not Indicated", SetCAT_Procedure)
CAT_ProcMenu.Add("&s - Pt proceeds with Sx", SetCAT_Procedure)
CAT_ProcMenu.Add("&d - Pt defers Sx", SetCAT_Procedure)

:b0*:cat;::
{
    Global Horiz, Vert, CAT_Severity, CAT_Laterality, CAT_Procedure

    SetKeyDelay 15 ; we have to shut down auto backspace and manually add it back in here because ecw is too slow to recognize a set amount of backspaces. It's consistently the same number of backspaces each time. Go figure. At least its consistently slow. 
    SendEvent("{Backspace 4}")

    CAT_Severity := ""        ;wipe all buckets clean so there is not data from last run leftover.
    CAT_Laterality := ""       
    CAT_Procedure := ""

    WinGetPos(&X, &Y, &W, &H, "A")
    Horiz := W / 2
    Vert := H / 4
    SetTimer(() => CATMenu.Show(Horiz, Vert), -10)
}

InsertMCAT(ItemName, ItemPos, MyMenu)
{
    SendDiagCode("CAT", "Educated pt on findings. Cataracts are not visually significant, no treatment required at this time. Continue to monitor with yearly exam.", "")
}

SetCAT_Severity(ItemName, ItemPos, MyMenu)
{
    Global CAT_Severity, Horiz, Vert
    
    ; Determine string based on which menu item was clicked
    if (ItemPos == 2)
        CAT_Severity := "becoming visually significant."
    else if (ItemPos == 3)
        CAT_Severity := "visually significant."
        
    ; Proceed to the laterality menu
    CAT_LatMenu.Show(Horiz, Vert)
}

SetCAT_Laterality(ItemName, ItemPos, MyMenu)
{
    Global CAT_Laterality, Horiz, Vert
    CAT_Laterality := RegExReplace(ItemName, "^&. - ")
    CAT_ProcMenu.Show(Horiz, Vert)
}

SetCAT_Procedure(ItemName, ItemPos, MyMenu)
{
    Global CAT_Procedure, Horiz, Vert
    switch ItemPos
    {
        case 1: ;sx not indicated
            CAT_Procedure := "Sx not indicated at this time. Continue to monitor yearly."
        case 2: ;proceeds with sx
            CAT_Procedure := "Pt elects to proceed with CAT Sx. Pt given QR code handout with link to CAT video playlist. Refer to TVN x na."
        case 3: ;defers sx 
            CAT_Procedure := "Pt elects to defer Sx, continue to monitor yearly."
    }        
    FinishCAT()  
}

FinishCAT()
{
    Global CAT_Severity, CAT_Laterality, CAT_Procedure
    h := "CAT " . CAT_Laterality

    ; Dynamically injects "becoming visually significant." or "visually significant."
    b := "CAT are " . CAT_Severity . " " . CAT_Procedure
    b2 := ""

    SendDiagCode(h, b, b2)
}
; #endregion

; ==============================================================================
; #region --- GLAUCOMA CUSTOM GUI ---
; ==============================================================================

Global GlcGui := ""

:b0*:glc;::
{
    global GlcGui, lastActiveHwnd
    lastActiveHwnd := WinActive("A")
    SetKeyDelay 15 
    SendEvent("{Backspace 4}") ; Clean up trigger text
    
    ; If the window already exists, just bring it to the front so you don't lose data
    if (GlcGui) {
        SetTimer(() => GlcGui.Show(), -10)
        return
    }

    ; Create the Persistent GUI (+AlwaysOnTop keeps it floating over eCW)
    GlcGui := Gui("+AlwaysOnTop", "Glaucoma Dashboard")
    
    ; If you click the 'X', just hide the window instead of destroying it
    GlcGui.OnEvent("Close", (*) => GlcGui.Hide()) 
    
    GlcGui.SetFont("s10", "Segoe UI")

    ; --- Row 1: Type and Eye ---
    GlcGui.Add("Text", "x10 y15 w40", "Type:")
    ; DropDownList forces you to pick an option
    GlcGui.Add("ComboBox", "x50 y10 w170 vGlcType Choose1", ["POAG", "Closed Angle", "OHTN", "Glc Suspect"])
    
    GlcGui.Add("Text", "x230 y15 w30", "Eye:")
    GlcGui.Add("DropDownList", "x260 y10 w60 vGlcEye Choose1", ["OD", "OS", "OU"])

    ; --- Row 2: Free Type Line ---
    GlcGui.Add("Text", "x10 y45 w80", "Gen Notes:")
    GlcGui.Add("Edit", "x90 y40 w230 vGlcNotes", "")

    ; --- Row 3: Fam Hx and Tx Init ---
    GlcGui.Add("Text", "x10 y75 w60", "Fam Hx:")
    GlcGui.Add("ComboBox", "x70 y70 w90 vGlcFamHx", ["negative", "positive"])

    GlcGui.Add("Text", "x165 y75 w55", "Tx Init:")
    GlcGui.Add("ComboBox", "x220 y70 w100 vGlcTxInit", ["unknown"])

    ; --- Row 4: Current Tx ---
    GlcGui.Add("Text", "x10 y105 w80", "Current Tx:")
    ; ComboBox lets you click the dropdown OR just free-type your own text
    GlcGui.Add("ComboBox", "x90 y100 w230 vGlcTx", ["monitoring", "lat QHS"]) 

    ; --- Row 5: TMax & Pach ---
    GlcGui.Add("Text", "x10 y135 w45", "TMax:")
    GlcGui.Add("Edit", "x55 y130 w95 vGlcTMax", "")
    
    GlcGui.Add("Text", "x155 y135 w40", "Pach:")
    GlcGui.Add("ComboBox", "x195 y130 w125 vGlcPach", ["n/a"])

    ; --- Row 6, 7, 8: Gonio, gOCT, VF ---
    GlcGui.Add("Text", "x10 y165 w45", "Gonio:")
    GlcGui.Add("Edit", "x55 y160 w265 vGlcGonio", "")

    GlcGui.Add("Text", "x10 y195 w45", "gOCT:")
    GlcGui.Add("Edit", "x55 y190 w265 vGlcgOCT", "")

    GlcGui.Add("Text", "x10 y225 w45", "VF:")
    GlcGui.Add("Edit", "x55 y220 w265 vGlcVF", "")

    ; --- Row 9: Notes (Bottom) ---
    GlcGui.Add("Text", "x10 y255 w45", "Notes:")
    GlcGui.Add("Edit", "x55 y250 w265 vGlcBottomNotes", "")

    ; --- Buttons ---
    ; "Default" means pressing Enter inside the form will trigger this button
    btnSubmit := GlcGui.Add("Button", "x60 y290 w100 Default", "Inject")
    btnSubmit.OnEvent("Click", SubmitGlcGui)
    
    btnCancel := GlcGui.Add("Button", "x170 y290 w90", "Cancel")
    btnCancel.OnEvent("Click", (*) => GlcGui.Hide())

    ; Render the window
    SetTimer(() => GlcGui.Show("w330 h330"), -10)
}

SubmitGlcGui(*) {
    Global GlcGui, lastActiveHwnd
    
    ; Save the data from the GUI (this hides the window automatically)
    saved := GlcGui.Submit() 
    
    ; Build the output string
    finalText := saved.GlcType . " " . saved.GlcEye . "`n"
    if (saved.GlcNotes != "")
        finalText .= saved.GlcNotes . "`n"
    
    finalText .= "*****`n"
    if (saved.GlcFamHx != "")
        finalText .= "Fam Hx: " . saved.GlcFamHx . "`n"
    if (saved.GlcTxInit != "")
        finalText .= "Tx Initiation: " . saved.GlcTxInit . "`n"
    finalText .= "Current Tx: " . saved.GlcTx . "`n"
    finalText .= "TMax: " . saved.GlcTMax . "`n"
    finalText .= "Pach: " . saved.GlcPach . "`n"
    finalText .= "Gonio: " . saved.GlcGonio . "`n"
    finalText .= "gOCT: " . saved.GlcgOCT . "`n"
    finalText .= "VF: " . saved.GlcVF . "`n"
    if (saved.GlcBottomNotes != "")
        finalText .= "Notes: " . saved.GlcBottomNotes . "`n"

    ; Reactivate previous active window and fast paste
    if (lastActiveHwnd && WinExist(lastActiveHwnd)) {
        WinActivate(lastActiveHwnd)
        if WinWaitActive(lastActiveHwnd,, 1) {
            Sleep(100)
            FastPaste(finalText)
        }
    } else {
        FastPaste(finalText)
    }
    
    ; Wipe the form clean so it is blank for the next patient. 
    GlcGui := "" 
}
; #endregion

; ==============================================================================
; #region --- PVD MACRO MENU ---
; ==============================================================================
PvdMenu := Menu()
PvdMenu.Add("PVD Laterality:", SetPvdEye)
PvdMenu.Disable("PVD Laterality:") ; Grey header
PvdMenu.Add() ; Separator line
PvdMenu.Add("&a - OD", SetPvdEye)
PvdMenu.Add("&s - OS", SetPvdEye)
PvdMenu.Add("&d - OU", SetPvdEye)

; --- THE PVD TRIGGER ---
:b0*:pvd;::
{
    SetKeyDelay 10
    SendEvent("{Backspace 4}")
    ; Get window center coordinates and show the menu
    WinGetPos(&X, &Y, &W, &H, "A")
    SetTimer(() => PvdMenu.Show(W / 2, H / 4), -10)
}

; #region --- THE PVD PRINTER ENGINE ---
SetPvdEye(ItemName, ItemPos, MyMenu)
{
    eye := RegExReplace(ItemName, "^&. - ")
    h := "PVD " . eye
    b := "Educ pt on benign nature of findings. Expect eventual reduction in size of floater and neuroadaptation over the course of several months. If increase in floaters, FoL, presence of curtain or veil over peripheral vision" . (eye = "OU" ? "" : ", or occurrance of same symptoms in fellow eye") . " then rtc promptly for eval.`nrtc x 1 mon for dil PVD fu."
    b2 := ""

    SendDiagCode(h, b, b2)
}
;#endregion

; ==============================================================================
; #region --- MANIFEST REFRACTION (MRx) MACRO MENU ---
; ==============================================================================
Global MRx_Option1 := ""
Global MRx_Option2 := ""
Global MRx_H := 0
Global MRx_V := 0

; -- First Menu --
MRxMenu := Menu()
MRxMenu.Add("MRx Options:", (*) => "")
MRxMenu.Disable("MRx Options:")
MRxMenu.Add()
MRxMenu.Add("&a - Finalize spec Rx.", SetMRx_Option1)
MRxMenu.Add("&s - Defer Final spec Rx.", SetMRx_Option1)
MRxMenu.Add("&d - Pt declines final spec Rx atm.", SetMRx_Option1)

; -- 2nd menu when option a --
MRx_Menu_A := Menu()
MRx_Menu_A.Add("Finalize spec Rx Options:", (*) => "")
MRx_Menu_A.Disable("Finalize spec Rx Options:")
MRx_Menu_A.Add()
MRx_Menu_A.Add("&a - No change compared to hab spec", SetMRx_Option2)
MRx_Menu_A.Add("&s - No change compared to previous MRx.", SetMRx_Option2)
MRx_Menu_A.Add("&d - Changes made for improved VA.", SetMRx_Option2)
MRx_Menu_A.Add("&f - Pt noted improvement when compared to hab spec.", SetMRx_Option2)
MRx_Menu_A.Add("&j - Pt noted improvement to DVA.", SetMRx_Option2)
MRx_Menu_A.Add("&g - Pt noted no improvement with changes.", SetMRx_Option2)

; -- 2nd menu when option s --
MRx_Menu_S := Menu()
MRx_Menu_S.Add("Defer Final spec Rx Options:", (*) => "")
MRx_Menu_S.Disable("Defer Final spec Rx Options:")
MRx_Menu_S.Add()
MRx_Menu_S.Add("&a - No spec required atm.", SetMRx_Option2)
MRx_Menu_S.Add("&s - BCVA limited by OSD.", SetMRx_Option2)
MRx_Menu_S.Add("&d - BCVA limited by retinal pathology.", SetMRx_Option2)
MRx_Menu_S.Add("&f - Pt noted no improvement with changes.", SetMRx_Option2)

; -- 2nd menu when option d --
MRx_Menu_D := Menu()
MRx_Menu_D.Add("Pt declines final spec Rx Options:", (*) => "")
MRx_Menu_D.Disable("Pt declines final spec Rx Options:")
MRx_Menu_D.Add()
MRx_Menu_D.Add("&a - Opts for otc readers only prn.", SetMRx_Option2)
MRx_Menu_D.Add("&s - Content with current spec.", SetMRx_Option2)
MRx_Menu_D.Add("&d - Skip (leave blank)", SetMRx_Option2)
MRx_Menu_D.Add("&f - Pt noted no improvement with changes.", SetMRx_Option2)

; --- THE MRx TRIGGER ---
:b0*:mrx;::
{
    SetKeyDelay 10
    SendEvent("{Backspace 4}")
    
    Global MRx_H, MRx_V, MRx_Option1, MRx_Option2
    MRx_Option1 := ""
    MRx_Option2 := ""
    
    WinGetPos(&X, &Y, &W, &H, "A")
    MRx_H := W / 2
    MRx_V := H / 4
    SetTimer(() => MRxMenu.Show(MRx_H, MRx_V), -10)
}

SetMRx_Option1(ItemName, ItemPos, MyMenu)
{
    Global MRx_Option1, MRx_H, MRx_V
    MRx_Option1 := RegExReplace(ItemName, "^&. - ")
    
    if (ItemPos == 3) {
        MRx_Menu_A.Show(MRx_H, MRx_V)
    } else if (ItemPos == 4) {
        MRx_Menu_S.Show(MRx_H, MRx_V)
    } else if (ItemPos == 5) {
        MRx_Menu_D.Show(MRx_H, MRx_V)
    }
}

SetMRx_Option2(ItemName, ItemPos, MyMenu)
{
    Global MRx_Option2
    MRx_Option2 := RegExReplace(ItemName, "^&. - ")
    FinishMRx()
}

FinishMRx()
{
    Global MRx_Option1, MRx_Option2
    
    outputText := MRx_Option1
    if (MRx_Option2 != "Skip (leave blank)") {
        outputText .= " " . MRx_Option2
    }
    
    outputText := Trim(outputText)
    if (SubStr(outputText, -1) != ".") {
        outputText .= "."
    }
    
    SendText(outputText)
}

ActiveCtrlIsNotEdit(winTitle) {
    try {
        focusedHwnd := ControlGetFocus(winTitle)
        ctrlClass := ControlGetClassNN(focusedHwnd)
        return !InStr(ctrlClass, "Edit")
    }
    return true
}
; #endregion