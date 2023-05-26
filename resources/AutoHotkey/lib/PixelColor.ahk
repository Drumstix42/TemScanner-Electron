; ? https://www.autohotkey.com/board/topic/38414-pixelcolorx-y-window-transp-off-screen-etc-windows/?p=242401
; Coordinates are related to the window's client area
; e.g. pxValue := PixelColorSimple("Window Name", 25, 25)
PixelColorSimple(pc_wID, pc_x, pc_y) {
    if (pc_wID) {
        pc_hDC := DllCall("GetDC", "UInt", pc_wID)
        pc_fmtI := A_FormatInteger
        SetFormat, IntegerFast, Hex
        pc_c := DllCall("GetPixel", "UInt", pc_hDC, "Int", pc_x, "Int", pc_y, "UInt")
        pc_c := pc_c >> 16 & 0xff | pc_c & 0xff00 | (pc_c & 0xff) << 16
        pc_c .= ""
        SetFormat, IntegerFast, %pc_fmtI%
        DllCall("ReleaseDC", "UInt", pc_wID, "UInt", pc_hDC)
        pc_c := "0x" SubStr("000000" SubStr(pc_c, 3), -5)
        return pc_c
    }
}