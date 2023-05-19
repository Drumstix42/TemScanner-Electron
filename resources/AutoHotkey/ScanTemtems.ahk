#SingleInstance, force ; force, ignore, off
#MaxThreadsPerHotkey 2
CoordMode, Screen

; Set Icon
I_ICON = %A_ScriptDir%\icon.ico
Menu, Tray, Icon, %I_ICON%

; Set Tray Title
Menu, Tray, Tip, % "Temtem OCR for Temscanner"

; ------------------------------
; LIBS
; ------------------------------
#include %A_ScriptDir%/lib/JSON.ahk
#include %A_ScriptDir%/lib/JSONFile.ahk
#include %A_ScriptDir%/lib/OCRScreenRegion.ahk
#include %A_ScriptDir%/lib/PixelColor.ahk

; ------------------------------
; DIRECTORY
; ------------------------------
global parentDirectory := SubStr(A_ScriptDir, 1, InStr(SubStr(A_ScriptDir,1,-1), "\", 0, 0)-1)
;MsgBox %parentDirectory%

; ------------------------------
; VARIABLES
; ------------------------------
global isScriptActive := 1

global WINDOW_NAME := "ahk_exe Temtem.exe"
global MINIMAP_BLUE_BORDER_COLOR := "0x3CE8EA"
global TEM_NAMEPLATE_BG_COLOR := "0x1E1E1E"

; positions are based on 2560x1440 resolution
global MINIMAP_BLUE_BORDER_X := 2360
global MINIMAP_BLUE_BORDER_Y := 45

global TEM_NAMEPLATE1_X := 2090
global TEM_NAMEPLATE1_Y := 204

global TEM_NAMEPLATE2_X := 1560
global TEM_NAMEPLATE2_Y := 130

global TEM_NAME_WIDTH := 310
global TEM_NAME_HEIGHT := 120

global TEM_NAME1_X_START := 2034
global TEM_NAME1_X_END := TEM_NAME1_X_START + TEM_NAME_WIDTH
global TEM_NAME1_Y_START := 108
global TEM_NAME1_Y_END := TEM_NAME1_X_START + TEM_NAME_HEIGHT

global TEM_NAME2_X_START := 1502
global TEM_NAME2_X_END := TEM_NAME2_X_START + TEM_NAME_WIDTH
global TEM_NAME2_Y_START := 34
global TEM_NAME2_Y_END := TEM_NAME2_Y_START + TEM_NAME_HEIGHT

; ------------------------------
; FUNCTIONS
; ------------------------------
isTem1Available() {
    pxValue := PixelColorSimple(WINDOW_NAME, TEM_NAMEPLATE1_X, TEM_NAMEPLATE1_Y)
    return pxValue = TEM_NAMEPLATE_BG_COLOR
}

isTem2Available() {
    pxValue := PixelColorSimple(WINDOW_NAME, TEM_NAMEPLATE2_X, TEM_NAMEPLATE2_Y)
    return pxValue = TEM_NAMEPLATE_BG_COLOR
}

isOutOfCombat() {
    pxValue := PixelColorSimple(WINDOW_NAME, MINIMAP_BLUE_BORDER_X, MINIMAP_BLUE_BORDER_Y)
    ; minimap doesn't show in combat
    return pxValue = MINIMAP_BLUE_BORDER_COLOR
}

isGameWindowAvailable(hWnd) {
    if WinExist(hWnd) {
        WinGet, wState, MinMax, hWnd
        if (wState = -1) {
            ; game is minimized
            return false
        }
        return true
    }
    return false
}

scanTemtems() {
    if !FileExist(parentDirectory . "/AutoHotkey/temdata.json") {
        ;MsgBox % parentDirectory "/AutoHotkey/temdata.json"
        FileAppend {}, % parentDirectory "/AutoHotkey/temdata.json"
    }

    if !WinActive(WINDOW_NAME) {
        return
    }
    ;if !isGameWindowAvailable(WINDOW_NAME) {
    ;    return
    ;}
    if isOutOfCombat() {
        return
    }
    if !isTem1Available() && !isTem2Available() {
        return
    }
    tem1 := ""
    tem2 := ""

    if isTem1Available() {
        tem1 := ocrScreenRegion(TEM_NAME1_X_START, TEM_NAME1_Y_START, TEM_NAME_WIDTH, TEM_NAME_HEIGHT, WINDOW_NAME)
    }
    if isTem2Available() {
        tem2 := ocrScreenRegion(TEM_NAME2_X_START, TEM_NAME2_Y_START, TEM_NAME_WIDTH, TEM_NAME_HEIGHT, WINDOW_NAME)
    }
    ;MsgBox, % tem1 tem2

    FormatTime, currentTime,, hh:mm:ss tt
    ; JSON ISO, UTC time
    FormatTime, currentDateTime, %A_NowUTC%, yyyy-MM-ddTHH:mm:ssZ

    jf := new JSONFile(parentDirectory "/AutoHotkey/temdata.json")
    jf.tem1 := { "name": Trim(tem1), "active": isTem1Available() }
    jf.tem2 := { "name": Trim(tem2), "active": isTem2Available() }
    jf.timestamp := currentTime
    jf.datetime := currentDateTime
    ;MsgBox % jf.Str()
    jf.Save()
    return
}

scanLoop() {
    loop {
        if !isScriptActive {
            break
        }
        scanTemtems()
        Sleep 1000
    }
}

; default to running loop until hotkey disables it
scanLoop()

; toggle the script on/off with Numpad0 (plays a beep on/off sound)
; the "~" ensures that the normal function of the key still works
~Numpad0::
    isScriptActive := !isScriptActive

    if isScriptActive {
        SetTimer, PlayEnableBeep, -1
        Tooltip, Script is ON, 0, 0
        SetTimer, RemoveTooltip, 1000
        scanLoop()
    } else {
        SetTimer, PlayDisableBeep, -1
        Tooltip, Script is OFF, 0, 0
        SetTimer, RemoveTooltip, 1000
    }
return

PlayEnableBeep() {
    SoundBeep 750, 700 ; higher tone
}

PlayDisableBeep() {
    SoundBeep 250, 500 ; lower tone
}

RemoveTooltip:
    ToolTip
return