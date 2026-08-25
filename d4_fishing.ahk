; ==============================================================================
; Diablo IV Fishing Buddy
;
; Copyright (c) 2026 SuperMilkers
; SPDX-License-Identifier: MIT
;
; Licensed under the MIT License.
; See the accompanying LICENSE file for the complete license text.
;
; This is an unofficial community project and is not affiliated with or
; endorsed by Blizzard Entertainment.
; ==============================================================================

#Requires AutoHotkey v1.1
#SingleInstance Force
#Include %A_ScriptDir%\engine\export.ahk

SetBatchLines, -1
SetKeyDelay, 50, 50

; Icon shown when a fish can be reeled in.
biteQuery := "|<>##101010$0/0/42D8C3,1/3/6DFDD6,-1/2/41DEC6,-2/1/3DC8B6"

; Icon confirming that fishing is active.
fishingQuery := "|<>*96$72.U00000U00000E00000U0000F800000U000027zzzzzzzzzzwLzzzzzzzzzzx7zzzzzzyzzrx7zzzzzwEDxzxLzzzzzy087zxLzzzzzr00Tzx7zzzzwn01zzx7nzrrsDU7zzx7lzxzzDkzzzx7uSDzyDzzzzw7ks3TyzDbzzwLtkVfTzTzzzxLVXtVDyk7zzxLV3svDyk3rzx7X7wzS1U4Tzx7X6gnszy87zx7V6sn7U7y3zx6V3liy007lzx7VU1dk000szx7Uk3v0000CTx70kCS00003Tx70UwA00001jx70UkM0M000zx71UUks4000Tx71VUVw2000Dx711VVa20007x711X1y30003x7X130w34101x7X360037101x7W360033y01x76260036600w7663U07w200w6A61s0Cw200Qzw40TzwA3U0T7wA03zXg3s0Q7sA00MDgHC2Q7sA00s3gF62R7s801c6AFX2R7sM038AK9VWR7kM06+SHj0mR7kM0Q8ANy0mR7kI0s9DPU0qRLUo1U+3uk0wpLUo70P1qE0sxLUqD0N0CM0lhLUyDkHFiC1XxLUj0kr8N7z3RLUU1Uq0sEs6xLUy9UwVc80AQLUrn1jX600Qg7UQ631q1U0sQ7kDw30Q003sw7s7s60700DMw7s00A0Dw1wEw7w00M0Azzthw7z01k0Dzswxw7zU7U0DzzzTw7yzy00Dzzzzx7yDk00TzzzrxLwU000TzzzxxLs8000TzzzzxLk0E20Tzzzzx7y20T0zzzzzx7jDVz0zzzzzxL7zVTszzzzzxK00H00zzzzzx7zzzzzzzzzzwU"

oGraphicSearch := new graphicsearch()

; Default reel key. Press F11 to change it.
reelKey := "5"

setupMode := true
ready := false
paused := true
changingReelKey := false
fishingActive := false
biteLatched := false

castX := 0
castY := 0

lastFishingSeen := 0
lastBiteSeen := 0
lastReel := 0
lastCast := 0

reelCooldown := 1500
castCooldown := 5000
noticeUntil := 0
noticeText := ""

; Zoom configuration.
zoomSteps := 4
zoomStepsSent := 0
zoomDelay := 500

; Incremented whenever automation state changes.
; This prevents an interrupted timer cycle from completing an old action.
stateVersion := 0

ShowStatus("SETUP REQUIRED`nMove the cursor over the Fishing option's position in the Action Wheel.`nLeft-click once to save the position and immediately start fishing.`nAny left-click will complete setup.")
return

WatchFishing:
    if (!ready || paused || setupMode || changingReelKey)
        return

    cycleVersion := stateVersion
    now := A_TickCount

    fishingResult := oGraphicSearch.search(fishingQuery)

    if (paused || cycleVersion != stateVersion)
        return

    if IsObject(fishingResult)
    {
        fishingActive := true
        lastFishingSeen := now

        biteResult := oGraphicSearch.search(biteQuery)

        if (paused || cycleVersion != stateVersion)
            return

        if IsObject(biteResult)
        {
            lastBiteSeen := now

            if (!biteLatched && now - lastReel > reelCooldown)
            {
                if (paused || cycleVersion != stateVersion)
                    return

                biteLatched := true
                lastReel := now

                reelSend := "{" reelKey "}"
                SendEvent, %reelSend%

                SoundBeep, 1500, 200
                noticeText := "FISH FOUND`nPRESSED " reelKey
                noticeUntil := A_TickCount + 2000
            }
        }
        else if (biteLatched && now - lastBiteSeen > 500)
        {
            biteLatched := false
        }

        defaultStatus := "FISHING ACTIVE`nWatching for a bite..."
    }
    else if (now - lastFishingSeen > 1200)
    {
        fishingActive := false
        biteLatched := false

        if (now - lastCast > castCooldown)
        {
            if (paused || cycleVersion != stateVersion)
                return

            lastCast := now

            ; Open the Action Wheel.
            SendEvent, {e}
            Sleep, 400

            if (paused || cycleVersion != stateVersion)
                return

            ; Select the saved Fishing option.
            MouseMove, %castX%, %castY%, 0
            Click

            if (paused || cycleVersion != stateVersion)
                return

            ; Zoom in only after the first casting click.
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

            noticeText := "CASTING`nPRESSED E + MOUSE CLICK`nZOOMED IN " zoomStepsSent " STEPS"
            noticeUntil := A_TickCount + 2000
        }

        defaultStatus := "NOT CURRENTLY FISHING`nAttempting to cast..."
    }
    else
    {
        defaultStatus := "Checking fishing state..."
    }

    if (paused || cycleVersion != stateVersion)
        return

    if (A_TickCount < noticeUntil)
        ShowRunningStatus(noticeText, cycleVersion)
    else
        ShowRunningStatus(defaultStatus, cycleVersion)
return

; Capture the Fishing option's screen position during setup.
#If (setupMode)

LButton::
    MouseGetPos, castX, castY

    stateVersion++
    setupMode := false
    ready := true
    paused := false
    fishingActive := false
    biteLatched := false

    ; Allow the first cast to happen immediately.
    lastCast := A_TickCount - castCooldown

    SoundBeep, 1000, 150
    ShowStatus("SETUP COMPLETE`nFishing option position: " castX ", " castY "`nFishing automation started.")

    SetTimer, WatchFishing, 100
return

#If

; Pause or resume the automation.
F8::
    if (!ready)
    {
        ShowStatus("Complete the Fishing option position setup first.")
        return
    }

    stateVersion++
    paused := !paused

    if (paused)
    {
        SetTimer, WatchFishing, Off
        ShowStatus("FISHING PAUSED")
    }
    else
    {
        ; Prevent an immediate recast when resuming.
        lastCast := A_TickCount

        SetTimer, WatchFishing, 100
        ShowStatus("FISHING RESUMED")
    }
return

; Choose a new Fishing option position.
F10::
    stateVersion++
    SetTimer, WatchFishing, Off

    paused := true
    ready := false
    setupMode := true
    fishingActive := false
    biteLatched := false

    ShowStatus("SETUP REQUIRED`nMove the cursor over the new Fishing option position in the Action Wheel.`nLeft-click once to save the position and immediately resume fishing.`nAny left-click will complete setup.")
return

; Change the reel key.
F11::
    if (changingReelKey)
        return

    stateVersion++
    changingReelKey := true
    previousPauseState := paused
    paused := true

    SetTimer, WatchFishing, Off
    ShowStatus("REEL KEY SETUP`nPress the new reel key now.")

    keyCapture := InputHook("L0")
    keyCapture.KeyOpt("{All}", "E")
    keyCapture.Start()
    keyCapture.Wait()

    newReelKey := keyCapture.EndKey

    if (newReelKey = "F8"
        || newReelKey = "F10"
        || newReelKey = "F11"
        || newReelKey = "Escape")
    {
        ShowStatus("That key is reserved.`nReel key remains: " reelKey)
    }
    else if (newReelKey != "")
    {
        reelKey := newReelKey
        SoundBeep, 1100, 150
        ShowStatus("REEL KEY CHANGED TO: " reelKey)
    }
    else
    {
        ShowStatus("No key was captured.`nReel key remains: " reelKey)
    }

    changingReelKey := false
    paused := previousPauseState

    if (!paused && ready && !setupMode)
        SetTimer, WatchFishing, 100
return

Esc::
    SetTimer, WatchFishing, Off
    ToolTip
    ExitApp
return

; Display running status only if the current timer cycle is still valid.
ShowRunningStatus(message, cycleVersion)
{
    global paused, stateVersion

    Critical, On

    if (!paused && cycleVersion = stateVersion)
        ShowStatus(message)

    Critical, Off
}

; Display the current status, reel key, and all controls.
ShowStatus(message)
{
    global reelKey

    controls := "`n`nReel key: " reelKey
    controls .= "`nF8: Pause/Resume"
    controls .= "`nF10: Change Fishing option position"
    controls .= "`nF11: Change reel key"
    controls .= "`nEsc: Quit"

    ToolTip, % message controls, 20, 20
}