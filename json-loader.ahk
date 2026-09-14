; =============================
; =====Global Directives=======
; =============================
#Requires AutoHotkey v2.0
#SingleInstance Force
#Hotstring EndChars -(){}:;,.?!`n `t  ; Ensure single quote (') is omitted
#Hotstring SI T
Persistent ; Force script to stay persistent

; ===========================
; ==== The JSON ENGINE ======
; ===========================
global jsonPath := A_ScriptDir "\matlock_macrows.json"
global macroList := []
global registeredTriggers := []

; Load macros on startup
LoadMacros()

LoadMacros() {
    global jsonPath, macroList
    
    if !FileExist(jsonPath) {
        MsgBox("Could not find the configuration file: " . jsonPath, "Error", "Iconx")
        ExitApp()
    }

    try {
        rawJson := FileRead(jsonPath)
        macroList := ParseSimpleJson(rawJson)
        RegisterAllHotstrings()
    } catch as err {
        MsgBox("Failed to load macros: " . err.Message, "Error", "Iconx")
    }
}

RegisterAllHotstrings() {
    global macroList, registeredTriggers
    
    ; 1. Disable all previously registered triggers
    for fullTrig in registeredTriggers {
        try {
            Hotstring(fullTrig, , "Off")
        }
    }
    registeredTriggers := []
    
    ; 2. Register current list of triggers
    for item in macroList {
        inp := item.HasOwnProp("input") ? item.input : (item.HasOwnProp("trigger") ? item.trigger : "")
        outp := item.HasOwnProp("output") ? item.output : ""
        
        if (inp != "") {
            trigType := item.HasOwnProp("triggerType") ? item.triggerType : (item.HasOwnProp("type") ? item.type : "Standard")
            
            ; Determine the prefix based on whether it needs an ending character
            prefix := (trigType = "Standard") ? "::" : ":*:" 
            fullTrig := prefix . inp
            
            try {
                ; Route standard text vs functional callbacks
                if (trigType = "Standard" || trigType = "Auto") {
                    Hotstring(fullTrig, outp, "On")
                } else {
                    actionCallback := CreateMacroAction(trigType, outp)
                    Hotstring(fullTrig, actionCallback, "On")
                }
                registeredTriggers.Push(fullTrig)
            }
        }
    }
}

; Factory function to lock in the variable scopes for the callbacks
CreateMacroAction(type, text) {
    if (type = "DxHeaderEnter")
        return (hs) => DxHeaderEnter(text)
    
    if (type = "SendOS")
        return (hs) => SendOS(text)
    
    if (type = "PrintRx") {
        ; Handles both empty print triggers and text + print triggers
        return (hs) => (text != "" ? (SendText(text), Sleep(100)) : 0, PrintRx())
    }
    
    ; Fallback
    return (hs) => SendText(text) 
}

; --- Lightweight JSON Parser Helper ---
ParseSimpleJson(jsonStr) {
    doc := ComObject("htmlfile")
    doc.write("<meta http-equiv='X-UA-Compatible' content='IE=edge'>")
    js := doc.parentWindow
    parsed := js.eval("(" . jsonStr . ")")
    jsGetProp := js.eval("(function(obj, key) { return (obj && key in obj && obj[key] !== null && obj[key] !== undefined) ? String(obj[key]) : ''; })")
    jsHasProp := js.eval("(function(obj, key) { return Boolean(obj && (key in obj) && obj[key] !== null && obj[key] !== undefined); })")
    
    resultList := []
    loop parsed.length {
        entry := parsed.%A_Index - 1%
        
        itemObj := {}
        
        ; Input (support 'input' and fallback 'trigger')
        if jsHasProp(entry, "input")
            itemObj.input := jsGetProp(entry, "input")
        else if jsHasProp(entry, "trigger")
            itemObj.input := jsGetProp(entry, "trigger")
        else
            itemObj.input := ""
            
        ; Output
        if jsHasProp(entry, "output")
            itemObj.output := jsGetProp(entry, "output")
        else
            itemObj.output := ""
            
        ; Trigger Type ("Standard" for :: and "Auto" for :*:)
        if jsHasProp(entry, "trigger type")
            itemObj.triggerType := jsGetProp(entry, "trigger type")
        else if jsHasProp(entry, "triggerType")
            itemObj.triggerType := jsGetProp(entry, "triggerType")
        else if jsHasProp(entry, "type") {
            tVal := jsGetProp(entry, "type")
            itemObj.triggerType := (tVal = "Auto" ? "Auto" : "Standard")
        } else {
            itemObj.triggerType := "Standard"
        }
        
        ; Category (support 'category' and 'Category')
        if jsHasProp(entry, "category")
            itemObj.category := jsGetProp(entry, "category")
        else if jsHasProp(entry, "Category")
            itemObj.category := jsGetProp(entry, "Category")
        else
            itemObj.category := ""
            
        ; Tags (support 'tags' and 'Tags')
        if jsHasProp(entry, "tags")
            itemObj.tags := jsGetProp(entry, "tags")
        else if jsHasProp(entry, "Tags")
            itemObj.tags := jsGetProp(entry, "Tags")
        else
            itemObj.tags := ""
            
        ; Note
        if jsHasProp(entry, "note")
            itemObj.note := jsGetProp(entry, "note")
        else
            itemObj.note := ""
            
        resultList.Push(itemObj)
    }
    return resultList
}

; Helper to check property existence on COM objects
ComHasProp(comObj, propName) {
    try {
        val := comObj.%propName%
        return true
    } catch {
        return false
    }
}

; ===========================
; ====== TRAY & HOTKEY ======
; ===========================
try {
    A_TrayMenu.Add() ; Add separator
    A_TrayMenu.Add("Edit JSON Macros", (*) => OpenMacroEditor())
}

#SuspendExempt
^+j::OpenMacroEditor() ; Ctrl + Shift + J opens the editor
#SuspendExempt False

; ===========================
; ==== MACRO EDITOR GUI =====
; ===========================
global editorGui := ""
global macroLV := ""
global filterEdit := ""
global inputEdit := ""
global typeDDL := ""
global outputEdit := ""
global categoryEdit := ""
global tagsEdit := ""
global noteEdit := ""
global selectedIndex := 0
global filteredMap := [] ; Maps ListView Row index to macroList index

OpenMacroEditor() {
    global editorGui, macroLV, filterEdit, inputEdit, typeDDL, outputEdit, categoryEdit, tagsEdit, noteEdit, selectedIndex
    
    if editorGui {
        editorGui.Show()
        PopulateListView()
        return
    }
    
    editorGui := Gui("+Resize", "JSON Macro Editor")
    editorGui.SetFont("s10", "Segoe UI")
    
    editorGui.Add("Text", "x10 y15", "Search Filter:")
    filterEdit := editorGui.Add("Edit", "x100 y12 w580")
    filterEdit.OnEvent("Change", OnFilterChange)
    
    macroLV := editorGui.Add("ListView", "x10 y45 w670 r15 Grid -Multi", ["Index", "Input", "Type", "Output", "Category", "Tags", "Note"])
    macroLV.OnEvent("ItemSelect", OnLVSelect)
    
    ; Form Fields
    editorGui.Add("GroupBox", "x10 y360 w670 h185", "Macro Details")
    
    editorGui.Add("Text", "x20 y385", "Input:")
    inputEdit := editorGui.Add("Edit", "x65 y382 w100")
    
    editorGui.Add("Text", "x175 y385", "Type:")
    typeDDL := editorGui.Add("DropDownList", "x215 y382 w110 Choose1", ["Standard", "Auto", "SendOS", "DxHeaderEnter", "PrintRx"])
    
    editorGui.Add("Text", "x335 y385", "Category:")
    categoryEdit := editorGui.Add("Edit", "x400 y382 w105")
    
    editorGui.Add("Text", "x515 y385", "Tags:")
    tagsEdit := editorGui.Add("Edit", "x555 y382 w115")
    
    editorGui.Add("Text", "x20 y420", "Output:")
    outputEdit := editorGui.Add("Edit", "x65 y417 w605 r3 +Multi +WantReturn")
    
    editorGui.Add("Text", "x20 y495", "Note:")
    noteEdit := editorGui.Add("Edit", "x65 y492 w605")
    
    ; Action Buttons
    btnAddUpdate := editorGui.Add("Button", "x10 y560 w130", "Add / Update")
    btnAddUpdate.OnEvent("Click", OnAddUpdate)
    
    btnDelete := editorGui.Add("Button", "x150 y560 w100", "Delete")
    btnDelete.OnEvent("Click", OnDelete)
    
    btnClearForm := editorGui.Add("Button", "x260 y560 w100", "Clear Form")
    btnClearForm.OnEvent("Click", OnClearForm)
    
    btnReloadScript := editorGui.Add("Button", "x370 y560 w110", "Reload Script")
    btnReloadScript.OnEvent("Click", (*) => Reload())
    
    btnClose := editorGui.Add("Button", "x570 y560 w110", "Close")
    btnClose.OnEvent("Click", (*) => editorGui.Hide())
    
    PopulateListView()
    editorGui.Show("w690 h600")
}

PopulateListView() {
    global macroLV, filteredMap, macroList, filterEdit
    
    macroLV.Opt("-Redraw")
    macroLV.Delete()
    filteredMap := []
    
    filterText := filterEdit ? filterEdit.Value : ""
    
    for idx, item in macroList {
        inp  := item.HasOwnProp("input") ? item.input : (item.HasOwnProp("trigger") ? item.trigger : "")
        tt   := item.HasOwnProp("triggerType") ? item.triggerType : "Standard"
        outp := item.HasOwnProp("output") ? item.output : ""
        cat  := item.HasOwnProp("category") ? item.category : ""
        tags := item.HasOwnProp("tags") ? item.tags : ""
        note := item.HasOwnProp("note") ? item.note : ""
        
        ; Match search term
        if (filterText != "") {
            searchString := inp . " " . tt . " " . outp . " " . cat . " " . tags . " " . note
            if !InStr(searchString, filterText)
                continue
        }
        
        ; Display preview of output (replace newlines with spaces for ListView row)
        outpPreview := StrReplace(outp, "`n", " ")
        outpPreview := StrReplace(outpPreview, "`r", "")
        
        macroLV.Add(, idx, inp, tt, outpPreview, cat, tags, note)
        filteredMap.Push(idx)
    }
    
    macroLV.ModifyCol(1, "45 Integer Left")
    macroLV.ModifyCol(2, "75 Left")
    macroLV.ModifyCol(3, "85 Left")
    macroLV.ModifyCol(4, "160 Left")
    macroLV.ModifyCol(5, "85 Left")
    macroLV.ModifyCol(6, "95 Left")
    macroLV.ModifyCol(7, "85 Left")
    
    macroLV.Opt("+Redraw")
}

OnFilterChange(*) {
    PopulateListView()
}

OnLVSelect(Ctrl, RowNumber, Selected) {
    global selectedIndex, macroList, filteredMap, inputEdit, typeDDL, outputEdit, categoryEdit, tagsEdit, noteEdit
    
    if (Selected = 0) {
        ; Deselected
        return
    }
    
    ; Get actual index in macroList
    actualIndex := filteredMap[RowNumber]
    selectedIndex := actualIndex
    
    item := macroList[actualIndex]
    inputEdit.Value := item.HasOwnProp("input") ? item.input : (item.HasOwnProp("trigger") ? item.trigger : "")
    
    trigType := item.HasOwnProp("triggerType") ? item.triggerType : "Standard"
    typeIndex := 1
    typeOptions := ["Standard", "Auto", "SendOS", "DxHeaderEnter", "PrintRx"]
    for idx, opt in typeOptions {
        if (opt = trigType) {
            typeIndex := idx
            break
        }
    }
    typeDDL.Choose(typeIndex)
    
    outputEdit.Value := item.HasOwnProp("output") ? item.output : ""
    categoryEdit.Value := item.HasOwnProp("category") ? item.category : ""
    tagsEdit.Value := item.HasOwnProp("tags") ? item.tags : ""
    noteEdit.Value := item.HasOwnProp("note") ? item.note : ""
}

OnClearForm(*) {
    global selectedIndex, inputEdit, typeDDL, outputEdit, categoryEdit, tagsEdit, noteEdit
    selectedIndex := 0
    inputEdit.Value := ""
    typeDDL.Choose(1)
    outputEdit.Value := ""
    categoryEdit.Value := ""
    tagsEdit.Value := ""
    noteEdit.Value := ""
}

OnAddUpdate(*) {
    global selectedIndex, macroList, inputEdit, typeDDL, outputEdit, categoryEdit, tagsEdit, noteEdit
    
    inp      := Trim(inputEdit.Value)
    trigType := typeDDL.Text
    outp     := outputEdit.Value
    cat      := Trim(categoryEdit.Value)
    tags     := Trim(tagsEdit.Value)
    note     := Trim(noteEdit.Value)
    
    if (inp == "") {
        MsgBox("Input / Trigger cannot be empty!", "Validation Error", "Iconx")
        return
    }
    
    ; Construct the object
    itemObj := {input: inp, output: outp, triggerType: trigType}
    if (cat != "")
        itemObj.category := cat
    if (tags != "")
        itemObj.tags := tags
    if (note != "")
        itemObj.note := note
    
    if (selectedIndex > 0) {
        ; Update existing macro
        macroList[selectedIndex] := itemObj
        MsgBox("Macro updated successfully!", "Success", "Iconi")
    } else {
        ; Check if input trigger already exists
        for idx, item in macroList {
            existingInp := item.HasOwnProp("input") ? item.input : (item.HasOwnProp("trigger") ? item.trigger : "")
            if (existingInp == inp) {
                if (MsgBox("Input '" inp "' already exists at index " idx ". Do you want to update it instead?", "Duplicate Input", "YesNo Icon?") == "Yes") {
                    macroList[idx] := itemObj
                    selectedIndex := idx
                }
                PopulateListView()
                return
            }
        }
        
        ; Add new macro
        macroList.Push(itemObj)
        MsgBox("New macro added successfully!", "Success", "Iconi")
    }
    
    ; Save changes and update UI
    SaveMacros()
    PopulateListView()
}

OnDelete(*) {
    global selectedIndex, macroList
    
    if (selectedIndex == 0) {
        MsgBox("Please select a macro from the list to delete.", "No Selection", "Icon!")
        return
    }
    
    item := macroList[selectedIndex]
    inpName := item.HasOwnProp("input") ? item.input : item.trigger
    if (MsgBox("Are you sure you want to delete macro '" inpName "'?", "Confirm Delete", "YesNo Icon?") == "Yes") {
        macroList.RemoveAt(selectedIndex)
        OnClearForm()
        SaveMacros()
        PopulateListView()
    }
}

SaveMacros() {
    global macroList, jsonPath
    
    jsonStr := StringifyJson(macroList)
    
    try {
        if FileExist(jsonPath)
            FileDelete(jsonPath)
        FileAppend(jsonStr, jsonPath, "UTF-8")
        RegisterAllHotstrings()
    } catch as err {
        MsgBox("Failed to save macros: " . err.Message, "Error", "Iconx")
    }
}

StringifyJson(macroList) {
    header := "/*`n"
           .  "==============================================================================`n"
           .  "CATEGORIES & TAGS REFERENCE GUIDE`n"
           .  "==============================================================================`n`n"
           .  "CATEGORIES:`n"
           .  "- Auto-Cap (Capitalization & standard abbreviations)`n"
           .  "    * Tags: vei team, vision and seeing, converging and diverging, imaging, lids, ocular findings and conditions, CL, general and medical`n"
           .  "- Refractive (Spectacle & Contact Lens Rx, Fit, Hygiene, and Modalities)`n"
           .  "    * Tags: Spec, PAL, Bifocal, Myopia Management, Presbyopia, Ergonomics, CL Fit, CL Care, CL Names`n"
           .  "- Assessment and Plan (Clinical plans, patient education, counseling, orders, management)`n"
           .  "    * Tags: Plan, Vision, Communication, Medication, Orders, Patient Education, Section Header, Billing`n"
           .  "- Exam Elements (Clinical findings, objective tests, exam notes, imaging)`n"
           .  "    * Tags: CL History, OSD, Posterior Segment, Dilation, Imaging`n`n"
           .  "TRIGGER TYPES:`n"
           .  "- `"Standard`" : Requires ending character (Space, Tab, Enter, etc.) -> Hotstring format: ::input`n"
           .  "- `"Auto`"     : Fires automatically upon completion -> Hotstring format: :*:input`n"
           .  "==============================================================================`n"
           .  "*/`n"

    json := header . "[`n"
    for index, item in macroList {
        inp := item.HasOwnProp("input") ? item.input : (item.HasOwnProp("trigger") ? item.trigger : "")
        outp := item.HasOwnProp("output") ? item.output : ""
        trigType := item.HasOwnProp("triggerType") ? item.triggerType : (item.HasOwnProp("type") ? item.type : "Standard")
        
        i := EscapeJsonStr(inp)
        o := EscapeJsonStr(outp)
        t := EscapeJsonStr(trigType)
        
        json .= "  {`n"
        json .= '    "input": "' i '",`n'
        json .= '    "output": "' o '",`n'
        json .= '    "trigger type": "' t '"'
        
        if item.HasOwnProp("category") && item.category != ""
            json .= ',`n    "category": "' EscapeJsonStr(item.category) '"'
        if item.HasOwnProp("tags") && item.tags != ""
            json .= ',`n    "tags": "' EscapeJsonStr(item.tags) '"'
        if item.HasOwnProp("note") && item.note != ""
            json .= ',`n    "note": "' EscapeJsonStr(item.note) '"'
            
        json .= "`n  }"
        
        if (index < macroList.Length)
            json .= ",`n"
        else
            json .= "`n"
    }
    json .= "]"
    return json
}

EscapeJsonStr(str) {
    str := StrReplace(str, "\", "\\")
    str := StrReplace(str, '"', '\"')
    str := StrReplace(str, "`n", "\n")
    str := StrReplace(str, "`r", "\r")
    str := StrReplace(str, "`t", "\t")
    return str
}