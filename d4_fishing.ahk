; ==============================================================================
; Diablo IV Fishing Buddy v1.2.0
;
; Copyright (c) 2026 SuperMilkers
; SPDX-License-Identifier: MIT
; Licensed under the MIT License.
;
; This is an unofficial community project and is not affiliated with or
; endorsed by Blizzard Entertainment.
; ==============================================================================

#Requires AutoHotkey v1.1
#SingleInstance Force
#Include %A_ScriptDir%\engine\export.ahk

SetBatchLines, -1
SetKeyDelay, 50, 50
SetTitleMatchMode, 2

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen


; ==============================================================================
; SETTINGS
; ==============================================================================

settingsFile := A_ScriptDir "\d4_fishing.ini"


; ==============================================================================
; 1440P DEFAULTS
; ==============================================================================

defaultActionWheelKey := "e"
defaultReelKey := "5"

defaultBiteBoxX := 1196
defaultBiteBoxY := 82
defaultBiteBoxW := 40
defaultBiteBoxH := 40

defaultFishingBoxX := 1020
defaultFishingBoxY := 1296
defaultFishingBoxW := 520
defaultFishingBoxH := 85

defaultCastEllipseX := 971
defaultCastEllipseY := 555
defaultCastEllipseW := 230
defaultCastEllipseH := 115


; ==============================================================================
; LOAD KEYBINDS
; ==============================================================================

IniRead, actionWheelKey, %settingsFile%, Keys, ActionWheel, %defaultActionWheelKey%
IniRead, reelKey, %settingsFile%, Keys, Reel, %defaultReelKey%


; ==============================================================================
; LOAD SAVED POSITIONS
; ==============================================================================

IniRead, biteBoxX, %settingsFile%, BiteBox, X, %defaultBiteBoxX%
IniRead, biteBoxY, %settingsFile%, BiteBox, Y, %defaultBiteBoxY%
IniRead, biteBoxW, %settingsFile%, BiteBox, Width, %defaultBiteBoxW%
IniRead, biteBoxH, %settingsFile%, BiteBox, Height, %defaultBiteBoxH%

IniRead, fishingBoxX, %settingsFile%, FishingBox, X, %defaultFishingBoxX%
IniRead, fishingBoxY, %settingsFile%, FishingBox, Y, %defaultFishingBoxY%
IniRead, fishingBoxW, %settingsFile%, FishingBox, Width, %defaultFishingBoxW%
IniRead, fishingBoxH, %settingsFile%, FishingBox, Height, %defaultFishingBoxH%

IniRead, castEllipseX, %settingsFile%, CastEllipse, X, %defaultCastEllipseX%
IniRead, castEllipseY, %settingsFile%, CastEllipse, Y, %defaultCastEllipseY%
IniRead, castEllipseW, %settingsFile%, CastEllipse, Width, %defaultCastEllipseW%
IniRead, castEllipseH, %settingsFile%, CastEllipse, Height, %defaultCastEllipseH%


; ==============================================================================
; SANITY CHECKS
; ==============================================================================

if (biteBoxW < 40)
    biteBoxW := 40

if (biteBoxH < 40)
    biteBoxH := 40

if (fishingBoxW < 40)
    fishingBoxW := 40

if (fishingBoxH < 40)
    fishingBoxH := 40

if (castEllipseW < 40)
    castEllipseW := 40

if (castEllipseH < 40)
    castEllipseH := 40


; ==============================================================================
; CYAN DETECTION
; ==============================================================================

cyanColor1 := 0x42D8C3
cyanColor2 := 0x6DFDD6
cyanColor3 := 0x41DEC6
cyanColor4 := 0x3DC8B6

cyanColors := [cyanColor1, cyanColor2, cyanColor3, cyanColor4]

cyanVariation := 40

cyanHitsRequired := 2
cyanHitCount := 0


; ==============================================================================
; FISHING ACTIVE QUERY
; ==============================================================================

fishingQuery := "|<>*96$72.U00000U00000E00000U0000F800000U000027zzzzzzzzzzwLzzzzzzzzzzx7zzzzzzyzzrx7zzzzzwEDxzxLzzzzzy087zxLzzzzzr00Tzx7zzzzwn01zzx7nzrrsDU7zzx7lzxzzDkzzzx7uSDzyDzzzzw7ks3TyzDbzzwLtkVfTzTzzzxLVXtVDyk7zzxLV3svDyk3rzx7X7wzS1U4Tzx7X6gnszy87zx7V6sn7U7y3zx6V3liy007lzx7VU1dk000szx7Uk3v0000CTx70kCS00003Tx70UwA00001jx70UkM0M000zx71UUks4000Tx71VUVw2000Dx711VVa20007x711X1y30003x7X130w34101x7X360037101x7W360033y01x76260036600w7663U07w200w6A61s0Cw200Qzw40TzwA3U0T7wA03zXg3s0Q7sA00MDgHC2Q7sA00s3gF62R7s801c6AFX2R7sM038AK9VWR7kM06+SHj0mR7kM0Q8ANy0mR7kI0s9DPU0qRLUo1U+3uk0wpLUo70P1qE0sxLUqD0N0CM0lhLUyDkHFiC1XxLUj0kr8N7z3RLUU1Uq0sEs6xLUy9UwVc80AQLUrn1jX600Qg7UQ631q1U0sQ7kDw30Q003sw7s7s60700DMw7s00A0Dw1wEw7w00M0Azzthw7z01k0Dzswxw7zU7U0DzzzTw7yzy00Dzzzzx7yDk00TzzzrxLwU000TzzzxxLs8000TzzzzxLk0E20Tzzzzx7y20T0zzzzzx7jDVz0zzzzzxL7zVTszzzzzxK00H00zzzzzx7zzzzzzzzzzwU"

oGraphicSearch := new graphicsearch()


; ==============================================================================
; AUTOMATION CONFIGURATION
; ==============================================================================

scanInterval := 100
fishingStateScanInterval := 800

paused := true
hasStarted := false
changingKeys := false

biteLatched := false
lastFishingDetected := false

lastFishingStateScan := 0
lastFishingSeen := 0
lastBiteSeen := 0
lastReel := 0
lastCast := 0

reelCooldown := 1000
castCooldown := 2500

noticeUntil := 0
noticeText := ""

zoomSteps := 4
zoomStepsSent := 0
zoomDelay := 500

stateVersion := 0


; ==============================================================================
; AREA EDITOR STATE
; ==============================================================================

editMode := false
selectedOverlay := ""

previousEditPauseState := true
previousKeybindPauseState := true

overlaysCreated := false

biteBoxHwnd := 0
fishingBoxHwnd := 0
castEllipseHwnd := 0

biteLabelHwnd := 0
fishingLabelHwnd := 0
castLabelHwnd := 0

; GUI control variables must be global in AHK v1.
BiteTop := ""
BiteBottom := ""
BiteLeft := ""
BiteRight := ""

FishingTop := ""
FishingBottom := ""
FishingLeft := ""
FishingRight := ""

BiteExternalText := ""
FishingExternalText := ""
CastExternalText := ""


; ==============================================================================
; STATUS WINDOW STATE
; ==============================================================================

statusCreated := false
statusHwnd := 0
statusMessage := ""

lastStatusMessage := ""
lastStatusHotkeyText := ""

StatusText := ""
StatusHotkeys := ""


; ==============================================================================
; WINDOW MESSAGES
; ==============================================================================

; WM_LBUTTONDOWN
OnMessage(0x201, "Overlay_LBUTTONDOWN")

; WM_NCHITTEST
OnMessage(0x84, "Overlay_NCHITTEST")


; ==============================================================================
; TIMERS
; ==============================================================================

SetTimer, FollowDiabloStatus, 500


; ==============================================================================
; START
; ==============================================================================

ShowStatus("READY - FISHING PAUSED")

return


; ==============================================================================
; MAIN LOOP
; ==============================================================================

WatchFishing:

    if (paused || changingKeys || editMode)
        return

    cycleVersion := stateVersion
    now := A_TickCount

    ; ==========================================================================
    ; BITE SEARCH AREA
    ; ==========================================================================

    biteSearchX1 := biteBoxX
    biteSearchY1 := biteBoxY
    biteSearchX2 := biteBoxX + biteBoxW - 1
    biteSearchY2 := biteBoxY + biteBoxH - 1

    ; ==========================================================================
    ; FAST CYAN SEARCH
    ; ==========================================================================

    cyanFound := false

    for _, cyanColor in cyanColors
    {
        PixelSearch, cyanX, cyanY, %biteSearchX1%, %biteSearchY1%, %biteSearchX2%, %biteSearchY2%, %cyanColor%, %cyanVariation%, Fast RGB

        if (!ErrorLevel)
        {
            cyanFound := true
            break
        }
    }

    if (paused || cycleVersion != stateVersion)
        return

    ; ==========================================================================
    ; REEL
    ; ==========================================================================

    if (cyanFound)
    {
        cyanHitCount++
        lastBiteSeen := now

        if (cyanHitCount >= cyanHitsRequired)
        {
            if (!biteLatched && now - lastReel > reelCooldown)
            {
                if (paused || cycleVersion != stateVersion)
                    return

                biteLatched := true
                lastReel := now

                SendConfiguredKey(reelKey)

                noticeText := "FISH FOUND - CYAN`nPRESSED " reelKey
                noticeUntil := A_TickCount + 2000

                ShowRunningStatus(noticeText, cycleVersion)
                return
            }
        }
    }
    else
    {
        cyanHitCount := 0

        if (biteLatched && now - lastBiteSeen > 500)
            biteLatched := false
    }

    ; ==========================================================================
    ; SLOWER FISHING-STATE SEARCH
    ; ==========================================================================

    if ((now - lastFishingStateScan) >= fishingStateScanInterval)
    {
        lastFishingStateScan := now

        fishingSearchX1 := fishingBoxX
        fishingSearchY1 := fishingBoxY
        fishingSearchX2 := fishingBoxX + fishingBoxW - 1
        fishingSearchY2 := fishingBoxY + fishingBoxH - 1

        fishingOptions := {x1: fishingSearchX1
            , y1: fishingSearchY1
            , x2: fishingSearchX2
            , y2: fishingSearchY2
            , findall: 0}

        fishingResult := oGraphicSearch.search(fishingQuery, fishingOptions)

        if (paused || cycleVersion != stateVersion)
            return

        if IsObject(fishingResult)
        {
            lastFishingDetected := true
            lastFishingSeen := now
        }
        else
        {
            lastFishingDetected := false
        }

        ; ======================================================================
        ; NOT FISHING / AUTO CAST
        ; ======================================================================

        if (!lastFishingDetected && now - lastFishingSeen > 1200)
        {
            biteLatched := false
            cyanHitCount := 0

            if (now - lastCast > castCooldown)
            {
                if (paused || cycleVersion != stateVersion)
                    return

                lastCast := now
                lastFishingStateScan := now

                ; ==============================================================
                ; OPEN ACTION WHEEL
                ; ==============================================================

                SendConfiguredKey(actionWheelKey)

                Sleep, 400

                if (paused || cycleVersion != stateVersion)
                    return

                ; ==============================================================
                ; RANDOM CLICK IN CAST ELLIPSE
                ; ==============================================================

                RandomClickCastEllipse()

                if (paused || cycleVersion != stateVersion)
                    return

                ; ==============================================================
                ; INITIAL ZOOM
                ; ==============================================================

                if (zoomStepsSent < zoomSteps)
                {
                    Sleep, %zoomDelay%

                    if (paused || cycleVersion != stateVersion)
                        return

                    Loop
                    {
                        if (zoomStepsSent >= zoomSteps)
                            break

                        if (paused || cycleVersion != stateVersion)
                            return

                        SendEvent, {WheelUp}
                        zoomStepsSent++

                        Sleep, 60
                    }
                }

                noticeText := "CASTING`nACTION WHEEL + RANDOM CAST CLICK"
                noticeUntil := A_TickCount + 2000
            }
        }
    }

    ; ==========================================================================
    ; STATUS
    ; ==========================================================================

    if (lastFishingDetected)
        defaultStatus := "FISHING ACTIVE`nWatching for a bite..."
    else if (now - lastFishingSeen > 1200)
        defaultStatus := "NOT CURRENTLY FISHING`nAttempting to cast..."
    else
        defaultStatus := "Checking fishing state..."

    if (paused || cycleVersion != stateVersion)
        return

    if (A_TickCount < noticeUntil)
        ShowRunningStatus(noticeText, cycleVersion)
    else
        ShowRunningStatus(defaultStatus, cycleVersion)

return


; ==============================================================================
; F8 - PAUSE / START FISHING
; ==============================================================================

F8::

    if (editMode)
    {
        ShowEditStatus()
        return
    }

    if (changingKeys)
        return

    stateVersion++

    if (paused)
    {
        paused := false
        biteLatched := false
        cyanHitCount := 0
        lastFishingDetected := false
        lastFishingStateScan := 0

        if (!hasStarted)
        {
            hasStarted := true
            lastCast := A_TickCount - castCooldown

            ShowStatus("FISHING STARTED")
        }
        else
        {
            lastCast := A_TickCount

            ShowStatus("FISHING RESUMED")
        }

        SetTimer, WatchFishing, %scanInterval%
    }
    else
    {
        paused := true
        biteLatched := false
        cyanHitCount := 0

        SetTimer, WatchFishing, Off

        ShowStatus("FISHING PAUSED")
    }

return


; ==============================================================================
; F9 - SET POSITIONS
; ==============================================================================

F9::

    if (changingKeys)
        return

    stateVersion++

    ; ==========================================================================
    ; OPEN EDITOR
    ; ==========================================================================

    if (!editMode)
    {
        previousEditPauseState := paused

        paused := true
        biteLatched := false
        cyanHitCount := 0

        SetTimer, WatchFishing, Off

        editMode := true
        selectedOverlay := ""

        CreateEditorOverlays()
        ShowEditorOverlays()

        SetTimer, SyncEditorWindows, 60

        UpdateOverlaySelection()
        ShowEditStatus()

        return
    }

    ; ==========================================================================
    ; SAVE EDITOR
    ; ==========================================================================

    SyncOverlayPositions()
    SaveAllRegions()

    SetTimer, SyncEditorWindows, Off

    HideEditorOverlays()

    editMode := false
    selectedOverlay := ""

    paused := previousEditPauseState

    SoundBeep, 1100, 120

    if (!paused)
    {
        lastCast := A_TickCount
        lastFishingStateScan := 0

        SetTimer, WatchFishing, %scanInterval%

        ShowStatus("POSITIONS SAVED`nFISHING RESUMED")
    }
    else
    {
        ShowStatus("POSITIONS SAVED`nFISHING PAUSED")
    }

return


; ==============================================================================
; F10 - SET KEYBINDS
; ==============================================================================

F10::

    if (editMode)
    {
        ShowEditStatus()
        return
    }

    if (changingKeys)
        return

    stateVersion++

    changingKeys := true
    previousKeybindPauseState := paused

    paused := true
    biteLatched := false
    cyanHitCount := 0

    SetTimer, WatchFishing, Off

    ; ==========================================================================
    ; ACTION WHEEL KEY
    ; ==========================================================================

    ShowStatus("KEYBIND SETUP`nPress your ACTION WHEEL key.`nCurrent: " actionWheelKey)

    capturedKey := CaptureSetupKey()

    if (capturedKey != "")
    {
        actionWheelKey := capturedKey
        IniWrite, %actionWheelKey%, %settingsFile%, Keys, ActionWheel

        SoundBeep, 1000, 100
    }

    Sleep, 250

    ; ==========================================================================
    ; REEL KEY
    ; ==========================================================================

    ShowStatus("KEYBIND SETUP`nPress your REEL key.`nCurrent: " reelKey)

    capturedKey := CaptureSetupKey()

    if (capturedKey != "")
    {
        reelKey := capturedKey
        IniWrite, %reelKey%, %settingsFile%, Keys, Reel

        SoundBeep, 1100, 100
    }

    changingKeys := false
    paused := previousKeybindPauseState

    if (!paused)
    {
        lastCast := A_TickCount
        lastFishingStateScan := 0

        SetTimer, WatchFishing, %scanInterval%

        ShowStatus("KEYBINDS SAVED`nAction Wheel: " actionWheelKey "`nReel: " reelKey "`nFISHING RESUMED")
    }
    else
    {
        ShowStatus("KEYBINDS SAVED`nAction Wheel: " actionWheelKey "`nReel: " reelKey "`nFISHING PAUSED")
    }

return


; ==============================================================================
; F12 - QUIT
; ==============================================================================

F12::

    SetTimer, WatchFishing, Off
    SetTimer, FollowDiabloStatus, Off
    SetTimer, SyncEditorWindows, Off

    ExitApp

return


; ==============================================================================
; F9 EDITOR HOTKEYS
; ==============================================================================

#If (editMode)

r::

    Reset1440pDefaults()

return

#If


; ==============================================================================
; ARROW KEY RESIZING
; ==============================================================================

#If (editMode && selectedOverlay != "")

Up::

    ResizeSelectedOverlay(0, GetResizeStep())

return


Down::

    ResizeSelectedOverlay(0, -GetResizeStep())

return


Right::

    ResizeSelectedOverlay(GetResizeStep(), 0)

return


Left::

    ResizeSelectedOverlay(-GetResizeStep(), 0)

return

#If


; ==============================================================================
; EDITOR SYNC TIMER
; ==============================================================================

SyncEditorWindows:

    if (editMode)
    {
        SyncOverlayPositions()
        PositionExternalLabels()
    }

return


; ==============================================================================
; STATUS FOLLOW TIMER
; ==============================================================================

FollowDiabloStatus:

    if (statusCreated)
        PositionStatusWindow()

return


; ==============================================================================
; SEND CONFIGURED KEY
; ==============================================================================

SendConfiguredKey(keyName)
{
    if (keyName = "")
        return

    keySend := "{" keyName "}"
    SendEvent, %keySend%
}


; ==============================================================================
; CAPTURE SETUP KEY
; ==============================================================================

CaptureSetupKey()
{
    Loop
    {
        keyCapture := InputHook("L0")
        keyCapture.KeyOpt("{All}", "E")
        keyCapture.Start()
        keyCapture.Wait()

        newKey := keyCapture.EndKey

        if (newKey = "")
            continue

        ; Reserved program hotkeys.
        if (newKey = "F8"
            || newKey = "F9"
            || newKey = "F10"
            || newKey = "F12")
        {
            SoundBeep, 500, 200
            continue
        }

        return newKey
    }
}


; ==============================================================================
; RESET TO 1440P DEFAULTS
; ==============================================================================

Reset1440pDefaults()
{
    global editMode
    global selectedOverlay

    global defaultActionWheelKey
    global defaultReelKey

    global defaultBiteBoxX
    global defaultBiteBoxY
    global defaultBiteBoxW
    global defaultBiteBoxH

    global defaultFishingBoxX
    global defaultFishingBoxY
    global defaultFishingBoxW
    global defaultFishingBoxH

    global defaultCastEllipseX
    global defaultCastEllipseY
    global defaultCastEllipseW
    global defaultCastEllipseH

    global actionWheelKey
    global reelKey

    global biteBoxX
    global biteBoxY
    global biteBoxW
    global biteBoxH

    global fishingBoxX
    global fishingBoxY
    global fishingBoxW
    global fishingBoxH

    global castEllipseX
    global castEllipseY
    global castEllipseW
    global castEllipseH

    global settingsFile

    if (!editMode)
        return

    biteBoxX := defaultBiteBoxX
    biteBoxY := defaultBiteBoxY
    biteBoxW := defaultBiteBoxW
    biteBoxH := defaultBiteBoxH

    fishingBoxX := defaultFishingBoxX
    fishingBoxY := defaultFishingBoxY
    fishingBoxW := defaultFishingBoxW
    fishingBoxH := defaultFishingBoxH

    castEllipseX := defaultCastEllipseX
    castEllipseY := defaultCastEllipseY
    castEllipseW := defaultCastEllipseW
    castEllipseH := defaultCastEllipseH

    actionWheelKey := defaultActionWheelKey
    reelKey := defaultReelKey

    selectedOverlay := ""

    ShowEditorOverlays()
    UpdateOverlaySelection()
    PositionExternalLabels()

    SaveAllRegions()

    IniWrite, %actionWheelKey%, %settingsFile%, Keys, ActionWheel
    IniWrite, %reelKey%, %settingsFile%, Keys, Reel

    SoundBeep, 900, 100
    SoundBeep, 1200, 100

    ShowEditStatus("1440P DEFAULTS RESTORED")
}


; ==============================================================================
; RANDOM CLICK INSIDE CAST ELLIPSE
; ==============================================================================

RandomClickCastEllipse()
{
    global castEllipseX
    global castEllipseY
    global castEllipseW
    global castEllipseH

    centerX := castEllipseX + (castEllipseW / 2)
    centerY := castEllipseY + (castEllipseH / 2)

    radiusX := (castEllipseW / 2) - 10
    radiusY := (castEllipseH / 2) - 10

    if (radiusX < 5)
        radiusX := 5

    if (radiusY < 5)
        radiusY := 5

    minX := Round(-radiusX)
    maxX := Round(radiusX)

    minY := Round(-radiusY)
    maxY := Round(radiusY)

    Loop, 100
    {
        Random, offsetX, %minX%, %maxX%
        Random, offsetY, %minY%, %maxY%

        ellipseTest := ((offsetX * offsetX) / (radiusX * radiusX))
            + ((offsetY * offsetY) / (radiusY * radiusY))

        if (ellipseTest <= 1)
        {
            clickX := Round(centerX + offsetX)
            clickY := Round(centerY + offsetY)

            MouseMove, %clickX%, %clickY%, 0
            Click

            return
        }
    }

    clickX := Round(centerX)
    clickY := Round(centerY)

    MouseMove, %clickX%, %clickY%, 0
    Click
}


; ==============================================================================
; CREATE EDITOR WINDOWS
; ==============================================================================

CreateEditorOverlays()
{
    global overlaysCreated

    global biteBoxHwnd
    global fishingBoxHwnd
    global castEllipseHwnd

    global biteLabelHwnd
    global fishingLabelHwnd
    global castLabelHwnd

    global BiteTop
    global BiteBottom
    global BiteLeft
    global BiteRight

    global FishingTop
    global FishingBottom
    global FishingLeft
    global FishingRight

    global BiteExternalText
    global FishingExternalText
    global CastExternalText

    if (overlaysCreated)
        return

    ; ==========================================================================
    ; BITE BOX
    ; ==========================================================================

    Gui, Bite:New, +AlwaysOnTop +ToolWindow -Caption +HwndbiteBoxHwnd
    Gui, Bite:Color, FFEAF3

    Gui, Bite:Add, Progress, x0 y0 w100 h5 cFF1493 BackgroundFF1493 vBiteTop, 100
    Gui, Bite:Add, Progress, x0 y0 w5 h100 cFF1493 BackgroundFF1493 vBiteLeft, 100
    Gui, Bite:Add, Progress, x0 y95 w100 h5 cFF1493 BackgroundFF1493 vBiteBottom, 100
    Gui, Bite:Add, Progress, x95 y0 w5 h100 cFF1493 BackgroundFF1493 vBiteRight, 100

    ; ==========================================================================
    ; BITE LABEL
    ; ==========================================================================

    Gui, BiteLabelGui:New, +AlwaysOnTop +ToolWindow -Caption +E0x20 +HwndbiteLabelHwnd
    Gui, BiteLabelGui:Color, 161616
    Gui, BiteLabelGui:Font, s9 Bold cFF69B4, Segoe UI
    Gui, BiteLabelGui:Add, Text, vBiteExternalText, BITE

    WinSet, Transparent, 235, ahk_id %biteLabelHwnd%

    ; ==========================================================================
    ; FISHING STATE BOX
    ; ==========================================================================

    Gui, Fishing:New, +AlwaysOnTop +ToolWindow -Caption +HwndfishingBoxHwnd
    Gui, Fishing:Color, EAF8FF

    Gui, Fishing:Add, Progress, x0 y0 w100 h5 c00AEEF Background00AEEF vFishingTop, 100
    Gui, Fishing:Add, Progress, x0 y0 w5 h100 c00AEEF Background00AEEF vFishingLeft, 100
    Gui, Fishing:Add, Progress, x0 y95 w100 h5 c00AEEF Background00AEEF vFishingBottom, 100
    Gui, Fishing:Add, Progress, x95 y0 w5 h100 c00AEEF Background00AEEF vFishingRight, 100

    ; ==========================================================================
    ; FISHING LABEL
    ; ==========================================================================

    Gui, FishingLabelGui:New, +AlwaysOnTop +ToolWindow -Caption +E0x20 +HwndfishingLabelHwnd
    Gui, FishingLabelGui:Color, 161616
    Gui, FishingLabelGui:Font, s9 Bold c39C5FF, Segoe UI
    Gui, FishingLabelGui:Add, Text, vFishingExternalText, FISHING STATE

    WinSet, Transparent, 235, ahk_id %fishingLabelHwnd%

    ; ==========================================================================
    ; CAST ELLIPSE
    ; ==========================================================================

    Gui, Cast:New, +AlwaysOnTop +ToolWindow -Caption +HwndcastEllipseHwnd
    Gui, Cast:Color, FFD95A

    ; ==========================================================================
    ; CAST LABEL
    ; ==========================================================================

    Gui, CastLabelGui:New, +AlwaysOnTop +ToolWindow -Caption +E0x20 +HwndcastLabelHwnd
    Gui, CastLabelGui:Color, 161616
    Gui, CastLabelGui:Font, s9 Bold cFFD95A, Segoe UI
    Gui, CastLabelGui:Add, Text, vCastExternalText, CAST BUTTON

    WinSet, Transparent, 235, ahk_id %castLabelHwnd%

    overlaysCreated := true
}


; ==============================================================================
; SHOW EDITOR
; ==============================================================================

ShowEditorOverlays()
{
    global biteBoxX
    global biteBoxY
    global biteBoxW
    global biteBoxH

    global fishingBoxX
    global fishingBoxY
    global fishingBoxW
    global fishingBoxH

    global castEllipseX
    global castEllipseY
    global castEllipseW
    global castEllipseH

    global biteBoxHwnd
    global fishingBoxHwnd
    global castEllipseHwnd

    ; ==========================================================================
    ; BITE
    ; ==========================================================================

    Gui, Bite:Show, x%biteBoxX% y%biteBoxY% w%biteBoxW% h%biteBoxH% NoActivate

    UpdateBiteBorder()

    WinSet, Transparent, 100, ahk_id %biteBoxHwnd%

    ; ==========================================================================
    ; FISHING STATE
    ; ==========================================================================

    Gui, Fishing:Show, x%fishingBoxX% y%fishingBoxY% w%fishingBoxW% h%fishingBoxH% NoActivate

    UpdateFishingBorder()

    WinSet, Transparent, 95, ahk_id %fishingBoxHwnd%

    ; ==========================================================================
    ; CAST
    ; ==========================================================================

    Gui, Cast:Show, x%castEllipseX% y%castEllipseY% w%castEllipseW% h%castEllipseH% NoActivate

    UpdateCastEllipseShape()

    WinSet, Transparent, 115, ahk_id %castEllipseHwnd%

    ; ==========================================================================
    ; LABELS
    ; ==========================================================================

    Gui, BiteLabelGui:Show, AutoSize NoActivate
    Gui, FishingLabelGui:Show, AutoSize NoActivate
    Gui, CastLabelGui:Show, AutoSize NoActivate

    PositionExternalLabels()
}


; ==============================================================================
; HIDE EDITOR
; ==============================================================================

HideEditorOverlays()
{
    Gui, Bite:Hide
    Gui, Fishing:Hide
    Gui, Cast:Hide

    Gui, BiteLabelGui:Hide
    Gui, FishingLabelGui:Hide
    Gui, CastLabelGui:Hide
}


; ==============================================================================
; CLICK SELECTION
; ==============================================================================

Overlay_LBUTTONDOWN(wParam, lParam, msg, hwnd)
{
    global editMode
    global selectedOverlay

    global biteBoxHwnd
    global fishingBoxHwnd
    global castEllipseHwnd

    if (!editMode)
        return

    rootHwnd := DllCall("GetAncestor", "Ptr", hwnd, "UInt", 2, "Ptr")

    clickedOverlay := ""

    if (rootHwnd = biteBoxHwnd)
        clickedOverlay := "BITE"

    else if (rootHwnd = fishingBoxHwnd)
        clickedOverlay := "FISHING"

    else if (rootHwnd = castEllipseHwnd)
        clickedOverlay := "CAST"

    else
        return

    ; First click only selects.
    if (selectedOverlay != clickedOverlay)
    {
        selectedOverlay := clickedOverlay

        UpdateOverlaySelection()
        ShowEditStatus()

        return
    }
}


; ==============================================================================
; MOUSE DRAG - MOVE SELECTED REGION ONLY
; ==============================================================================

Overlay_NCHITTEST(wParam, lParam, msg, hwnd)
{
    global editMode
    global selectedOverlay

    global biteBoxHwnd
    global fishingBoxHwnd
    global castEllipseHwnd

    if (!editMode)
        return

    rootHwnd := DllCall("GetAncestor", "Ptr", hwnd, "UInt", 2, "Ptr")

    currentType := ""

    if (rootHwnd = biteBoxHwnd)
        currentType := "BITE"
    else if (rootHwnd = fishingBoxHwnd)
        currentType := "FISHING"
    else if (rootHwnd = castEllipseHwnd)
        currentType := "CAST"
    else
        return

    ; A region must be clicked/selected before it can be moved.
    if (currentType != selectedOverlay)
        return 1

    ; HTCAPTION: drag anywhere inside the selected region to move it.
    ; Mouse resizing is intentionally disabled. Arrow keys resize.
    return 2
}


; ==============================================================================
; KEEP SAVED COORDINATES IN SYNC WITH WINDOWS
; ==============================================================================

SyncOverlayPositions()
{
    global biteBoxHwnd
    global fishingBoxHwnd
    global castEllipseHwnd

    global biteBoxX
    global biteBoxY
    global biteBoxW
    global biteBoxH

    global fishingBoxX
    global fishingBoxY
    global fishingBoxW
    global fishingBoxH

    global castEllipseX
    global castEllipseY
    global castEllipseW
    global castEllipseH

    if (biteBoxHwnd)
    {
        oldW := biteBoxW
        oldH := biteBoxH

        WinGetPos, newX, newY, newW, newH, ahk_id %biteBoxHwnd%

        biteBoxX := newX
        biteBoxY := newY
        biteBoxW := (newW < 40) ? 40 : newW
        biteBoxH := (newH < 40) ? 40 : newH

        if (biteBoxW != oldW || biteBoxH != oldH)
            UpdateBiteBorder()
    }

    if (fishingBoxHwnd)
    {
        oldW := fishingBoxW
        oldH := fishingBoxH

        WinGetPos, newX, newY, newW, newH, ahk_id %fishingBoxHwnd%

        fishingBoxX := newX
        fishingBoxY := newY
        fishingBoxW := (newW < 40) ? 40 : newW
        fishingBoxH := (newH < 40) ? 40 : newH

        if (fishingBoxW != oldW || fishingBoxH != oldH)
            UpdateFishingBorder()
    }

    if (castEllipseHwnd)
    {
        oldW := castEllipseW
        oldH := castEllipseH

        WinGetPos, newX, newY, newW, newH, ahk_id %castEllipseHwnd%

        castEllipseX := newX
        castEllipseY := newY
        castEllipseW := (newW < 40) ? 40 : newW
        castEllipseH := (newH < 40) ? 40 : newH

        if (castEllipseW != oldW || castEllipseH != oldH)
            UpdateCastEllipseShape()
    }
}


; ==============================================================================
; EXTERNAL LABEL POSITIONS
; ==============================================================================

PositionExternalLabels()
{
    global biteBoxX
    global biteBoxY

    global fishingBoxX
    global fishingBoxY

    global castEllipseX
    global castEllipseY

    global biteLabelHwnd
    global fishingLabelHwnd
    global castLabelHwnd

    labelGap := 27

    biteLabelX := biteBoxX
    biteLabelY := biteBoxY - labelGap

    fishingLabelX := fishingBoxX
    fishingLabelY := fishingBoxY - labelGap

    castLabelX := castEllipseX
    castLabelY := castEllipseY - labelGap

    WinMove, ahk_id %biteLabelHwnd%,, %biteLabelX%, %biteLabelY%
    WinMove, ahk_id %fishingLabelHwnd%,, %fishingLabelX%, %fishingLabelY%
    WinMove, ahk_id %castLabelHwnd%,, %castLabelX%, %castLabelY%
}


; ==============================================================================
; SELECTED APPEARANCE
; ==============================================================================

UpdateOverlaySelection()
{
    global selectedOverlay

    global biteBoxHwnd
    global fishingBoxHwnd
    global castEllipseHwnd

    global BiteExternalText
    global FishingExternalText
    global CastExternalText

    biteAlpha := 100
    fishingAlpha := 95
    castAlpha := 115

    if (selectedOverlay = "BITE")
        biteAlpha := 180

    if (selectedOverlay = "FISHING")
        fishingAlpha := 175

    if (selectedOverlay = "CAST")
        castAlpha := 185

    WinSet, Transparent, %biteAlpha%, ahk_id %biteBoxHwnd%
    WinSet, Transparent, %fishingAlpha%, ahk_id %fishingBoxHwnd%
    WinSet, Transparent, %castAlpha%, ahk_id %castEllipseHwnd%

    if (selectedOverlay = "BITE")
        GuiControl, BiteLabelGui:, BiteExternalText, BITE - SELECTED
    else
        GuiControl, BiteLabelGui:, BiteExternalText, BITE

    if (selectedOverlay = "FISHING")
        GuiControl, FishingLabelGui:, FishingExternalText, FISHING STATE - SELECTED
    else
        GuiControl, FishingLabelGui:, FishingExternalText, FISHING STATE

    if (selectedOverlay = "CAST")
        GuiControl, CastLabelGui:, CastExternalText, CAST BUTTON - SELECTED
    else
        GuiControl, CastLabelGui:, CastExternalText, CAST BUTTON

    Gui, BiteLabelGui:Show, AutoSize NoActivate
    Gui, FishingLabelGui:Show, AutoSize NoActivate
    Gui, CastLabelGui:Show, AutoSize NoActivate

    PositionExternalLabels()
}


; ==============================================================================
; KEYBOARD RESIZE SPEED
; ==============================================================================

GetResizeStep()
{
    if GetKeyState("Ctrl", "P")
        return 200

    if GetKeyState("Shift", "P")
        return 75

    return 25
}


; ==============================================================================
; KEYBOARD RESIZE
; ==============================================================================

ResizeSelectedOverlay(changeW, changeH)
{
    global selectedOverlay

    global biteBoxHwnd
    global fishingBoxHwnd
    global castEllipseHwnd

    global biteBoxX
    global biteBoxY
    global biteBoxW
    global biteBoxH

    global fishingBoxX
    global fishingBoxY
    global fishingBoxW
    global fishingBoxH

    global castEllipseX
    global castEllipseY
    global castEllipseW
    global castEllipseH

    if (selectedOverlay = "")
        return

    ; ==========================================================================
    ; BITE
    ; ==========================================================================

    if (selectedOverlay = "BITE")
    {
        WinGetPos, currentX, currentY, currentW, currentH, ahk_id %biteBoxHwnd%

        newW := currentW + changeW
        newH := currentH + changeH

        if (newW < 40)
            newW := 40

        if (newH < 40)
            newH := 40

        biteBoxX := currentX
        biteBoxY := currentY
        biteBoxW := newW
        biteBoxH := newH

        Gui, Bite:Show, x%biteBoxX% y%biteBoxY% w%biteBoxW% h%biteBoxH% NoActivate

        UpdateBiteBorder()
    }

    ; ==========================================================================
    ; FISHING STATE
    ; ==========================================================================

    if (selectedOverlay = "FISHING")
    {
        WinGetPos, currentX, currentY, currentW, currentH, ahk_id %fishingBoxHwnd%

        newW := currentW + changeW
        newH := currentH + changeH

        if (newW < 40)
            newW := 40

        if (newH < 40)
            newH := 40

        fishingBoxX := currentX
        fishingBoxY := currentY
        fishingBoxW := newW
        fishingBoxH := newH

        Gui, Fishing:Show, x%fishingBoxX% y%fishingBoxY% w%fishingBoxW% h%fishingBoxH% NoActivate

        UpdateFishingBorder()
    }

    ; ==========================================================================
    ; CAST ELLIPSE
    ; ==========================================================================

    if (selectedOverlay = "CAST")
    {
        WinGetPos, currentX, currentY, currentW, currentH, ahk_id %castEllipseHwnd%

        newW := currentW + changeW
        newH := currentH + changeH

        if (newW < 40)
            newW := 40

        if (newH < 40)
            newH := 40

        castEllipseX := currentX
        castEllipseY := currentY
        castEllipseW := newW
        castEllipseH := newH

        Gui, Cast:Show, x%castEllipseX% y%castEllipseY% w%castEllipseW% h%castEllipseH% NoActivate

        UpdateCastEllipseShape()
    }

    PositionExternalLabels()
    ShowEditStatus()
}


; ==============================================================================
; BITE BORDER
; ==============================================================================

UpdateBiteBorder()
{
    global biteBoxW
    global biteBoxH

    if (biteBoxW < 40 || biteBoxH < 40)
        return

    rightX := biteBoxW - 5
    bottomY := biteBoxH - 5

    GuiControl, Bite:Move, BiteTop, % "x0 y0 w" biteBoxW " h5"
    GuiControl, Bite:Move, BiteLeft, % "x0 y0 w5 h" biteBoxH
    GuiControl, Bite:Move, BiteBottom, % "x0 y" bottomY " w" biteBoxW " h5"
    GuiControl, Bite:Move, BiteRight, % "x" rightX " y0 w5 h" biteBoxH
}


; ==============================================================================
; FISHING BORDER
; ==============================================================================

UpdateFishingBorder()
{
    global fishingBoxW
    global fishingBoxH

    if (fishingBoxW < 40 || fishingBoxH < 40)
        return

    rightX := fishingBoxW - 5
    bottomY := fishingBoxH - 5

    GuiControl, Fishing:Move, FishingTop, % "x0 y0 w" fishingBoxW " h5"
    GuiControl, Fishing:Move, FishingLeft, % "x0 y0 w5 h" fishingBoxH
    GuiControl, Fishing:Move, FishingBottom, % "x0 y" bottomY " w" fishingBoxW " h5"
    GuiControl, Fishing:Move, FishingRight, % "x" rightX " y0 w5 h" fishingBoxH
}


; ==============================================================================
; CAST ELLIPSE SHAPE
; ==============================================================================

UpdateCastEllipseShape()
{
    global castEllipseHwnd
    global castEllipseW
    global castEllipseH

    if (!castEllipseHwnd)
        return

    region := "0-0 W" castEllipseW " H" castEllipseH " E"

    WinSet, Region, %region%, ahk_id %castEllipseHwnd%
}


; ==============================================================================
; SAVE REGIONS
; ==============================================================================

SaveAllRegions()
{
    global settingsFile

    global biteBoxX
    global biteBoxY
    global biteBoxW
    global biteBoxH

    global fishingBoxX
    global fishingBoxY
    global fishingBoxW
    global fishingBoxH

    global castEllipseX
    global castEllipseY
    global castEllipseW
    global castEllipseH

    IniWrite, %biteBoxX%, %settingsFile%, BiteBox, X
    IniWrite, %biteBoxY%, %settingsFile%, BiteBox, Y
    IniWrite, %biteBoxW%, %settingsFile%, BiteBox, Width
    IniWrite, %biteBoxH%, %settingsFile%, BiteBox, Height

    IniWrite, %fishingBoxX%, %settingsFile%, FishingBox, X
    IniWrite, %fishingBoxY%, %settingsFile%, FishingBox, Y
    IniWrite, %fishingBoxW%, %settingsFile%, FishingBox, Width
    IniWrite, %fishingBoxH%, %settingsFile%, FishingBox, Height

    IniWrite, %castEllipseX%, %settingsFile%, CastEllipse, X
    IniWrite, %castEllipseY%, %settingsFile%, CastEllipse, Y
    IniWrite, %castEllipseW%, %settingsFile%, CastEllipse, Width
    IniWrite, %castEllipseH%, %settingsFile%, CastEllipse, Height
}


; ==============================================================================
; EDITOR STATUS
; ==============================================================================

ShowEditStatus(extraMessage := "")
{
    global selectedOverlay

    global biteBoxHwnd
    global fishingBoxHwnd
    global castEllipseHwnd

    selectedText := "NONE"

    if (selectedOverlay = "BITE")
    {
        selectedText := "BITE BOX"
        WinGetPos, x, y, w, h, ahk_id %biteBoxHwnd%
    }
    else if (selectedOverlay = "FISHING")
    {
        selectedText := "FISHING STATE BOX"
        WinGetPos, x, y, w, h, ahk_id %fishingBoxHwnd%
    }
    else if (selectedOverlay = "CAST")
    {
        selectedText := "CAST BUTTON"
        WinGetPos, x, y, w, h, ahk_id %castEllipseHwnd%
    }

    text := "SET POSITIONS"

    if (extraMessage != "")
        text .= "`n" extraMessage

    text .= "`nSelected: " selectedText

    if (selectedOverlay != "")
    {
        text .= "`nPosition: " x "," y
        text .= "`nSize: " w "x" h
    }

    text .= "`n"
    text .= "`nClick a region to SELECT it."
    text .= "`nDrag the selected region to MOVE it."
    text .= "`n"
    text .= "`nUP = Taller"
    text .= "`nDOWN = Shorter"
    text .= "`nRIGHT = Wider"
    text .= "`nLEFT = Narrower"
    text .= "`n"
    text .= "`nArrow = 25 px"
    text .= "`nShift + Arrow = 75 px"
    text .= "`nCtrl + Arrow = 200 px"
    text .= "`n"
    text .= "`nR Reset 1440p Defaults"
    text .= "`nF9 = SAVE POSITIONS"

    ShowStatus(text)
}


; ==============================================================================
; RUNNING STATUS
; ==============================================================================

ShowRunningStatus(message, cycleVersion)
{
    global paused
    global stateVersion

    Critical, On

    if (!paused && cycleVersion = stateVersion)
        ShowStatus(message)

    Critical, Off
}


; ==============================================================================
; STATUS WINDOW
; ==============================================================================

ShowStatus(message)
{
    global statusCreated
    global statusHwnd
    global statusMessage

    global lastStatusMessage
    global lastStatusHotkeyText

    global actionWheelKey
    global reelKey

    global StatusText
    global StatusHotkeys

    if (!statusCreated)
    {
        Gui, Status:New, +AlwaysOnTop +ToolWindow -Caption +HwndstatusHwnd +E0x20
        Gui, Status:Color, 111111
        Gui, Status:Margin, 12, 10
        Gui, Status:Font, s10 cFFFFFF, Segoe UI

        Gui, Status:Add, Text, vStatusText x12 y10 w350 h40, Starting...
        Gui, Status:Add, Text, vStatusHotkeys x12 y58 w350 h120, Hotkeys

        statusCreated := true
    }

    hotkeyText := "Action Wheel: " actionWheelKey
    hotkeyText .= "`nReel: " reelKey
    hotkeyText .= "`n"
    hotkeyText .= "`nF8  Pause/Start Fishing"
    hotkeyText .= "`nF9  Set Positions"
    hotkeyText .= "`nF10 Set Keybinds"
    hotkeyText .= "`nF12 Quit"

    ; Skip expensive GUI work when nothing visible changed.
    if (message = lastStatusMessage && hotkeyText = lastStatusHotkeyText)
        return

    lastStatusMessage := message
    lastStatusHotkeyText := hotkeyText
    statusMessage := message

    ; Calculate heights from actual line counts.
    StringReplace, statusTemp, statusMessage, `n, `n, UseErrorLevel
    statusLines := ErrorLevel + 1

    StringReplace, hotkeyTemp, hotkeyText, `n, `n, UseErrorLevel
    hotkeyLines := ErrorLevel + 1

    ; Segoe UI 10pt is about 19 px per line here.
    lineHeight := 19

    statusH := (statusLines * lineHeight) + 4
    hotkeyH := (hotkeyLines * lineHeight) + 4

    if (statusH < 24)
        statusH := 24

    if (hotkeyH < 24)
        hotkeyH := 24

    hotkeysY := 10 + statusH + 8
    windowW := 374
    windowH := hotkeysY + hotkeyH + 10

    GuiControl, Status:, StatusText, %statusMessage%
    GuiControl, Status:, StatusHotkeys, %hotkeyText%

    GuiControl, Status:Move, StatusText, % "x12 y10 w350 h" statusH
    GuiControl, Status:Move, StatusHotkeys, % "x12 y" hotkeysY " w350 h" hotkeyH

    Gui, Status:Show, % "w" windowW " h" windowH " NoActivate", Diablo IV Fishing Buddy

    WinSet, Transparent, 225, ahk_id %statusHwnd%
    WinSet, AlwaysOnTop, On, ahk_id %statusHwnd%

    PositionStatusWindow()
}


; ==============================================================================
; STATUS FOLLOWS DIABLO WINDOW
; ==============================================================================

PositionStatusWindow()
{
    global statusHwnd

    if (!statusHwnd)
        return

    gameHwnd := GetDiabloWindow()

    if (gameHwnd)
    {
        WinGetPos, gameX, gameY, gameW, gameH, ahk_id %gameHwnd%

        statusX := gameX + 20
        statusY := gameY + 20
    }
    else
    {
        statusX := 20
        statusY := 20
    }

    WinMove, ahk_id %statusHwnd%,, %statusX%, %statusY%
    WinSet, AlwaysOnTop, On, ahk_id %statusHwnd%
}


; ==============================================================================
; FIND DIABLO IV
; ==============================================================================

GetDiabloWindow()
{
    hwnd := WinExist("ahk_exe Diablo IV.exe")

    if (hwnd)
        return hwnd

    return WinExist("Diablo IV")
}
