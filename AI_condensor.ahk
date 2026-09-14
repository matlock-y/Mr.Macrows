; ==============================================================================
; Local AI Clinical Summarizer (AHK v2)
; Endpoint: Local Ollama running qwen2.5:1.5b
; HOTKEY: Highlight text and press Ctrl + Alt + S
; ==============================================================================

^!a::SummarizeSelectedText()

SummarizeSelectedText() {
    targetHwnd := WinActive("A")
    
    ; 1. Preserve clipboard and grab highlighted text
    oldClip := ClipboardAll()
    A_Clipboard := ""
    Send("^c")
    if !ClipWait(1) {
        ToolTip("⚠️ No text selected to summarize!")
        SetTimer(() => ToolTip(), -2000)
        A_Clipboard := oldClip
        return
    }
    
    rawText := Trim(A_Clipboard)
    A_Clipboard := oldClip
    
    if (rawText == "")
        return
        
    ToolTip("🧠 Condensing note...")
    
    ; 2. Build system instruction & prompt
    systemPrompt := "You are a precise, no-nonsense ophthalmic scribe. "
                 . "Your job is to condense rambling patient narratives into strict, professional HPI statements. "
                 . "RULES:`n"
                 . "1. Use standard abbreviations (OD, OS, OU, FBS, cc, sc, pt, c/o, h/o).`n"
                 . "2. Retain all laterality, onset, duration, and pertinent negatives.`n"
                 . "3. Output ONLY the clinical summary. Never include conversational filler like 'Here is the summary'.`n"
                 . "4. Keep it to one or two concise sentences.`n`n"
                 . "EXAMPLE INPUT: My right eye has been tearing up since Monday and it feels like sand is in it. I used visine but it didn't help. Left eye is totally fine.`n"
                 . "EXAMPLE OUTPUT: Pt c/o epiphora and FBS OD x 3 days. No relief with OTC Visine. (-) symptoms OS."
    
    ; 3. Query local model in background
    summary := QueryLocalLLM(rawText, systemPrompt)
    ToolTip() ; Clear tooltip
    
    if (summary == "") {
        ToolTip("❌ Failed to get response from local LLM.")
        SetTimer(() => ToolTip(), -2500)
        return
    }
    
    ; 4. Present review GUI
    ShowSummaryPreview(summary, targetHwnd)
}

QueryLocalLLM(userInput, systemInstruction) {
    endpoint := "http://localhost:11434/api/generate"
    modelName := "qwen2.5:1.5b" 
    
    ; Escape strings for JSON payload
    cleanPrompt := StrReplace(userInput, "\", "\\")
    cleanPrompt := StrReplace(cleanPrompt, '"', '\"')
    cleanPrompt := StrReplace(cleanPrompt, "`n", "\n")
    cleanPrompt := StrReplace(cleanPrompt, "`r", "\r")
    
    cleanSystem := StrReplace(systemInstruction, "\", "\\")
    cleanSystem := StrReplace(cleanSystem, '"', '\"')
    cleanSystem := StrReplace(cleanSystem, "`n", "\n") ; Added fix for system prompt newlines
    cleanSystem := StrReplace(cleanSystem, "`r", "\r") ; Added fix for system prompt carriage returns
    
    payload := '{"model": "' modelName '", "prompt": "' cleanPrompt '", "system": "' cleanSystem '", "stream": false}'
    
    try {
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.Open("POST", endpoint, false)
        http.SetRequestHeader("Content-Type", "application/json")
        http.SetTimeouts(2000, 2000, 10000, 10000)
        http.Send(payload)
        
        if (http.Status != 200)
            return ""
            
        response := http.ResponseText
        
        ; Lightweight JSON regex extractor for Ollama response key
        if RegExMatch(response, 's)"response"\s*:\s*"(.*?)"\s*,\s*"done"', &match) {
            extracted := match[1]
            extracted := StrReplace(extracted, "\n", "`n")
            extracted := StrReplace(extracted, '\"', '"')
            extracted := StrReplace(extracted, "\\", "\")
            return Trim(extracted)
        }
    } catch {
        return ""
    }
    return ""
}

; ==============================================================================
; Preview & Injection GUI
; ==============================================================================
ShowSummaryPreview(condensedText, targetHwnd := 0) {
    static previewGui := ""
    if previewGui {
        try previewGui.Destroy()
    }
    
    previewGui := Gui("+AlwaysOnTop +Resize", "Clinical Summary Preview")
    previewGui.SetFont("s10", "Segoe UI")
    
    editBox := previewGui.Add("Edit", "x10 y10 w480 r5 Multi", condensedText)
    
    btnInject := previewGui.Add("Button", "x10 y145 w150 Default", "Inject to Chart (Enter)")
    btnCopy := previewGui.Add("Button", "x170 y145 w120", "Copy Only")
    btnCancel := previewGui.Add("Button", "x300 y145 w90", "Cancel")
    
    btnInject.OnEvent("Click", (*) => OnInject(previewGui, editBox, targetHwnd))
    btnCopy.OnEvent("Click", (*) => (val := editBox.Value, previewGui.Destroy(), A_Clipboard := val, ToolTip("📋 Copied!"), SetTimer(() => ToolTip(), -1500)))
    btnCancel.OnEvent("Click", (*) => previewGui.Destroy())
    previewGui.OnEvent("Escape", (*) => previewGui.Destroy())
    
    previewGui.Show("w500 h185")
}

OnInject(guiObj, editCtrl, targetHwnd) {
    textToInject := editCtrl.Value
    guiObj.Destroy()
    if (targetHwnd && WinExist("ahk_id " . targetHwnd)) {
        WinActivate("ahk_id " . targetHwnd)
    }
    Sleep(120)
    SendText(textToInject)
}