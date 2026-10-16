#Requires AutoHotkey v2.0
#SingleInstance Force
A_MenuMaskKey := "vkE8"   ; stops the Start menu opening when Win is released

; ================= SETTINGS =================
MODE       := "toggle"    ; "hold"   = dictate while Ctrl+Win held, finish on release
                          ; "toggle" = each Ctrl+Win press starts / finishes
CLAUDE_EXE := "claude.exe"
BTN_START  := "Dictate"            ; Claude's accessible button names
BTN_FINISH := "Finish dictation"
ACTIVATE   := true                 ; bring Claude to the front on press
; ============================================
; Finds Claude's buttons by name via Windows UI Automation (built into
; Windows), so it works at any window size, sidebar open or closed,
; and on the new-chat screen. No mouse movement.

A_IconTip := "Claude Mic Hotkey (" MODE ")"
UIA := ComObject("{ff48dba4-60ef-4201-aa87-54103eef594e}", "{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}")
COND_START  := MakeButtonCond(BTN_START)
COND_FINISH := MakeButtonCond(BTN_FINISH)

if (A_Args.Length && A_Args[1] = "/test") {   ; self-test: start, wait, finish
    h := GetClaudeWindow()
    r1 := h && Press(h, COND_START)
    Sleep 1500
    r2 := h && WaitPress(h, COND_FINISH, 1500)
    FileAppend "window=" (h ? 1 : 0) " start=" r1 " finish=" r2 "`n", "*"
    ExitApp
}

; ---- Ctrl+Win (either press order) ----
^LWin::
#LCtrl::
{
    hwnd := GetClaudeWindow()
    if !hwnd
        return Tip("Claude window not found")
    if ACTIVATE && !WinActive(hwnd)
        WinActivate hwnd

    if (MODE = "toggle") {
        if !Press(hwnd, COND_FINISH) && !Press(hwnd, COND_START)
            Tip("Dictate button not found")
        KeyWait "LWin"
        KeyWait "Ctrl"
        return
    }

    ; hold mode
    if !Press(hwnd, COND_START) {
        if !Press(hwnd, COND_FINISH)          ; already dictating -> finish
            Tip("Dictate button not found")
        KeyWait "LWin"
        KeyWait "Ctrl"
        return
    }
    while GetKeyState("LWin", "P") && GetKeyState("Ctrl", "P")
        Sleep 20
    if !WaitPress(hwnd, COND_FINISH, 1500)
        Tip("Couldn't find Finish dictation")
}

; Retry until the button appears (dictation UI can take a moment).
WaitPress(hwnd, cond, timeoutMs) {
    end := A_TickCount + timeoutMs
    loop {
        if Press(hwnd, cond)
            return true
        if (A_TickCount > end)
            return false
        Sleep 100
    }
}

; ---- UI Automation helpers (IUIAutomation vtable calls) ----
; Find first descendant matching cond under hwnd and Invoke it.
Press(hwnd, cond) {
    root := 0, el := 0, pat := 0
    try {
        ComCall(6, UIA, "ptr", hwnd, "ptr*", &root)          ; ElementFromHandle
        if !root
            return false
        ComCall(5, root, "int", 4, "ptr", cond, "ptr*", &el) ; FindFirst(Descendants)
        if !el
            return false
        ComCall(16, el, "int", 10000, "ptr*", &pat)          ; GetCurrentPattern(Invoke)
        if !pat
            return false
        ComCall(3, pat)                                      ; Invoke()
        return true
    } catch
        return false
    finally {
        for p in [pat, el, root]
            if p
                ObjRelease(p)
    }
}

; Condition: ControlType = Button AND Name = name
MakeButtonCond(name) {
    cName := 0, cType := 0, cAnd := 0
    v := Buffer(24, 0)
    NumPut("ushort", 8, v, 0)                                ; VT_BSTR
    bstr := DllCall("oleaut32\SysAllocString", "wstr", name, "ptr")
    NumPut("ptr", bstr, v, 8)
    ComCall(23, UIA, "int", 30005, "ptr", v, "ptr*", &cName) ; Name
    DllCall("oleaut32\SysFreeString", "ptr", bstr)
    t := Buffer(24, 0)
    NumPut("ushort", 3, t, 0)                                ; VT_I4
    NumPut("int", 50000, t, 8)                               ; Button
    ComCall(23, UIA, "int", 30003, "ptr", t, "ptr*", &cType) ; ControlType
    ComCall(25, UIA, "ptr", cName, "ptr", cType, "ptr*", &cAnd)
    ObjRelease(cName), ObjRelease(cType)
    return cAnd
}

GetClaudeWindow() {
    if (h := WinActive("ahk_exe " CLAUDE_EXE))
        return h
    for hwnd in WinGetList("ahk_exe " CLAUDE_EXE)
        if (WinGetTitle(hwnd) != "")
            return hwnd
    return 0
}

Tip(msg) {
    ToolTip msg
    SetTimer () => ToolTip(), -2000
}
