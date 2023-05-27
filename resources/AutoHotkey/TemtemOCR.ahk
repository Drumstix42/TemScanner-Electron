#SingleInstance, force ; force, ignore, off
#MaxThreadsPerHotkey 2
CoordMode, Pixel, Client

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

; ------------------------------
; DIRECTORY
; ------------------------------
global parentDirectory := SubStr(A_ScriptDir, 1, InStr(SubStr(A_ScriptDir,1,-1), "\", 0, 0)-1)
;MsgBox %parentDirectory%

; ------------------------------
; WAIT FOR GAME WINDOW
; ------------------------------
While !WinExist("ahk_exe Temtem.exe")
    Sleep, 500

; ------------------------------
; VARIABLES
; ------------------------------
global isScriptActive := 1

global WINDOW_EXE := "ahk_exe Temtem.exe"
global WINDOW_UID := WinExist(WINDOW_EXE)

global MINIMAP_BLUE_BORDER_COLOR := "0x3CE8EA"
global TEM_NAMEPLATE_BG_COLOR := "0x1E1E1E"

; GET WINDOW SIZE
WinGetPos, winX, winY, WINDOW_W, WINDOW_H, %WINDOW_EXE%
;MsgBox App Size %WINDOW_W% x %WINDOW_H%

; GET WINDOW CLIENT SIZE
VarSetCapacity(RECT, 16, 0)
DllCall("user32\GetClientRect", Ptr, WINDOW_UID, Ptr, &RECT)
DllCall("user32\ClientToScreen", Ptr, WINDOW_UID, Ptr, &RECT)
;global WIN_CLIENT_X := NumGet(&RECT, 0, "Int")
;global WIN_CLIENT_Y := NumGet(&RECT, 4, "Int")
global WINDOW_CLIENT_W := NumGet(&RECT, 8, "Int")
global WINDOW_CLIENT_H := NumGet(&RECT, 12, "Int")
;MsgBox Client Size %WINDOW_CLIENT_W% x %WINDOW_CLIENT_H%

; ! Sometimes the window size is the expected size, and sometimes the client is the expected size (based on Windowed vs Borderless)
; * Window resolution table
global r2560x1440 := { "MINIMAP_BLUE_BORDER_X": 2360, "MINIMAP_BLUE_BORDER_Y": 45, "TEM_NAMEPLATE1_X": 2090, "TEM_NAMEPLATE1_Y": 204, "TEM_NAMEPLATE2_X": 1560, "TEM_NAMEPLATE2_Y": 130, "TEM_NAME_WIDTH": 310, "TEM_NAME_HEIGHT": 120, "TEM_NAME1_X_START": 2034, "TEM_NAME1_Y_START": 108, "TEM_NAME2_X_START": 1502, "TEM_NAME2_Y_START": 34 }
global r1920x1080 := { "MINIMAP_BLUE_BORDER_X": 1760, "MINIMAP_BLUE_BORDER_Y": 30, "TEM_NAMEPLATE1_X": 1557, "TEM_NAMEPLATE1_Y": 150, "TEM_NAMEPLATE2_X": 1185, "TEM_NAMEPLATE2_Y": 95, "TEM_NAME_WIDTH": 250, "TEM_NAME_HEIGHT": 90, "TEM_NAME1_X_START": 1530, "TEM_NAME1_Y_START": 76, "TEM_NAME2_X_START": 1150, "TEM_NAME2_Y_START": 23 }
global RESOLUTIONS_TABLE := { "r2560x1440": r2560x1440, "r1920x1080": r1920x1080 }

global RESOLUTION_WINDOW_KEY := "r" . WINDOW_W . "x" . WINDOW_H
global RESOLUTION_CLIENT_KEY := "r" . WINDOW_CLIENT_W . "x" . WINDOW_CLIENT_H
global RESOLUTION_KEY := ""

if (RESOLUTIONS_TABLE.HasKey(RESOLUTION_WINDOW_KEY))
{
    RESOLUTION_KEY := RESOLUTION_WINDOW_KEY
}
else if (RESOLUTIONS_TABLE.HasKey(RESOLUTION_CLIENT_KEY))
{
    RESOLUTION_KEY := RESOLUTION_CLIENT_KEY
}
else
{
    MsgBox % "TemScanner OCR does not support your game resolution. No config found for " . RESOLUTION_WINDOW_KEY . " or " . RESOLUTION_CLIENT_KEY
    ExitApp
}

global MINIMAP_BLUE_BORDER_X := RESOLUTIONS_TABLE[RESOLUTION_KEY]["MINIMAP_BLUE_BORDER_X"]
global MINIMAP_BLUE_BORDER_Y := RESOLUTIONS_TABLE[RESOLUTION_KEY]["MINIMAP_BLUE_BORDER_Y"]

; nameplates determine availability of an enemy Temtem on the battlefield
global TEM_NAMEPLATE1_X := RESOLUTIONS_TABLE[RESOLUTION_KEY]["TEM_NAMEPLATE1_X"]
global TEM_NAMEPLATE1_Y := RESOLUTIONS_TABLE[RESOLUTION_KEY]["TEM_NAMEPLATE1_Y"]
global TEM_NAMEPLATE2_X := RESOLUTIONS_TABLE[RESOLUTION_KEY]["TEM_NAMEPLATE2_X"]
global TEM_NAMEPLATE2_Y := RESOLUTIONS_TABLE[RESOLUTION_KEY]["TEM_NAMEPLATE2_Y"]

global TEM_NAME_WIDTH := RESOLUTIONS_TABLE[RESOLUTION_KEY]["TEM_NAME_WIDTH"]
global TEM_NAME_HEIGHT := RESOLUTIONS_TABLE[RESOLUTION_KEY]["TEM_NAME_HEIGHT"]

; these coordinates define the OCR area within the Template (with some padding to help OCR sucess rate)
global TEM_NAME1_X_START := RESOLUTIONS_TABLE[RESOLUTION_KEY]["TEM_NAME1_X_START"]
global TEM_NAME1_X_END := TEM_NAME1_X_START + TEM_NAME_WIDTH
global TEM_NAME1_Y_START := RESOLUTIONS_TABLE[RESOLUTION_KEY]["TEM_NAME1_Y_START"]
global TEM_NAME1_Y_END := TEM_NAME1_X_START + TEM_NAME_HEIGHT

global TEM_NAME2_X_START := RESOLUTIONS_TABLE[RESOLUTION_KEY]["TEM_NAME2_X_START"]
global TEM_NAME2_X_END := TEM_NAME2_X_START + TEM_NAME_WIDTH
global TEM_NAME2_Y_START := RESOLUTIONS_TABLE[RESOLUTION_KEY]["TEM_NAME2_Y_START"]
global TEM_NAME2_Y_END := TEM_NAME2_Y_START + TEM_NAME_HEIGHT

; ------------------------------
; FUNCTIONS
; ------------------------------
isTem1Available() {
    PixelGetColor, pxValue, TEM_NAMEPLATE1_X, TEM_NAMEPLATE1_Y, RGB
    ;Tooltip, %pxValue% - resolution: %RESOLUTION_KEY%, 0, 0
    return pxValue = TEM_NAMEPLATE_BG_COLOR
}

isTem2Available() {
    PixelGetColor, pxValue, TEM_NAMEPLATE2_X, TEM_NAMEPLATE2_Y, RGB
    return pxValue = TEM_NAMEPLATE_BG_COLOR
}

isOutOfCombat() {
    PixelGetColor, pxValue, MINIMAP_BLUE_BORDER_X, MINIMAP_BLUE_BORDER_Y, RGB
    ; * minimap doesn't show in combat
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
        ; * Create the file if it doesn't exist
        FileAppend {}, % parentDirectory "/AutoHotkey/temdata.json"
    }

    if !WinActive(WINDOW_EXE) {
        return
    }
    ;if !isGameWindowAvailable(WINDOW_EXE) {
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
        tem1 := ocrScreenRegion(TEM_NAME1_X_START, TEM_NAME1_Y_START, TEM_NAME_WIDTH, TEM_NAME_HEIGHT, WINDOW_EXE)
    }
    if isTem2Available() {
        tem2 := ocrScreenRegion(TEM_NAME2_X_START, TEM_NAME2_Y_START, TEM_NAME_WIDTH, TEM_NAME_HEIGHT, WINDOW_EXE)
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
;~Numpad0::
;    isScriptActive := !isScriptActive
;
;    if isScriptActive {
;        SetTimer, PlayEnableBeep, -1
;        Tooltip, Script is ON, 0, 0
;        SetTimer, RemoveTooltip, 1000
;        scanLoop()
;    } else {
;        SetTimer, PlayDisableBeep, -1
;        Tooltip, Script is OFF, 0, 0
;        SetTimer, RemoveTooltip, 1000
;    }
;return

PlayEnableBeep() {
    SoundBeep 750, 700 ; higher tone
}

PlayDisableBeep() {
    SoundBeep 250, 500 ; lower tone
}

RemoveTooltip:
    ToolTip
return