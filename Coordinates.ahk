#Requires AutoHotkey v2.0

; ==============================================================================
; COORDINATES CONFIGURATION FILE
; ==============================================================================
global Coords := {
    ; --- Check-Out Script Coordinates ---
    ; Room In/Out box
    RoomInX: 56,
    RoomInY: 222,

    ; Out of Room box
    OutOfRoomX: 767,
    OutOfRoomY: 606,

    ; Save box
    SaveX: 1135,
    SaveY: 700,

    ; View Progress Note Down Caret
    StatusCaretX: 820,
    StatusCaretY: 222,

    ; Change Visit Status box
    StatusChangeX: 770,
    StatusChangeY: 430,

    ; Hit selection box (AC/Botox)
    StatusSelectX: 890,
    StatusSelectY: 460,

    ; --- Template Queue Script Coordinates ---
    ; Template Tab location coordinates
    TemplateTabX: 0,
    TemplateTabY: 0,

    ; Template Search box location coordinates
    SearchBoxX: 500,
    SearchBoxY: 300,

    ; --- Print Rx Script Coordinates ---
    PrintRxX: 0,
    PrintRxY: 0,
}
