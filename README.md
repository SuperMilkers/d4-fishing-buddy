# Diablo IV Fishing Buddy

An AutoHotkey v1 script that uses GraphicSearch to automate Diablo IV fishing. It selects Fishing from a saved Action Wheel position, detects the fishing and bite indicators, and presses a configurable reel key.

Copyright (c) 2026 SuperMilkers. Released under the MIT License.

## Demonstration

![Diablo IV Fishing Buddy demonstration](assets/d4_fishing_buddy_AHK.gif)

## Community

Join the Discord for help, updates, and discussion: [discord.gg/gvgbacUHcN](https://discord.gg/gvgbacUHcN)

## Requirements

- Windows 10 or Windows 11
- [AutoHotkey v1.1.37.02](https://www.autohotkey.com/download/1.1/AutoHotkey_1.1.37.02_setup.exe)
- Diablo IV running in borderless-windowed mode
- [GraphicSearch](https://github.com/Chunjee/graphicsearch.ahk) files included in the `engine` folder

AutoHotkey v2 is not compatible with this script. Versions 1 and 2 can be installed together because the script uses `#Requires AutoHotkey v1.1`.

## Installation

1. Install AutoHotkey v1.1.37.02.
2. Download and extract this repository.
3. Confirm that `engine\export.ahk` exists.
4. Start Diablo IV and move to a fishing location.
5. Double-click `d4_fishing.ahk`.

If Windows uses the wrong AutoHotkey version, run the script explicitly with v1:

```bat
"C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU64.exe" "C:\path\to\d4_fishing.ahk"
```

## Setup on Every Launch

The Fishing option position is stored only while the script is running:

1. Stand near fishable water and face it.
2. Start `d4_fishing.ahk`.
3. Press `E` to open the Diablo IV Action Wheel.
4. Move the pointer over **Fishing** and left-click it.
5. The script records the position and begins monitoring automatically.

You do not need to press `F10` during startup. Use `F10` only to change the Fishing option position afterward.

After the first cast, the script scrolls up five times to zoom in for more reliable bite detection.

## Hotkeys

| Hotkey | Action |
| --- | --- |
| `F8` | Pause or resume automation |
| `F10` | Choose a new Fishing option position |
| `F11` | Change the reel key |
| `Esc` | Quit |

The default reel key is `5`. The selector accepts one keyboard key at a time. Do not assign `F8`, `F10`, `F11`, or `Esc` because the script reserves them.

## Gameplay Notes

- Fish on a low difficulty, such as Normal.
- Face fishable water before starting.
- Fish must be picked up manually.
- Equip some Thorns in case nearby enemies attack or you fish up an enemy.
- If **Diablo reconnecting** appears in the upper-left corner, wait for it to clear.
- Keep the resolution, UI scale, and hotbar layout consistent.

## Rare Fish Locations

These six yellow Rare fish are required for **The One That Got Away**. Each fish is tied to a region, so other fishable water in the same region may also work.

| Rare fish | Region | Suggested location |
| --- | --- | --- |
| Augur of Civo | Dry Steppes | Beach west of Ked Bardu |
| Morayaga | Fractured Peaks | Bridge east of Yelesna |
| Crookfish | Hawezar | Walkway east of Backwater |
| Zakarati | Kehjistan | Docks southwest of Gea Kul |
| Neme-Senga | Nahantu | Pier west of Kurast Docks |
| Drakonbeard | Scosglen | Pier west of Marowen |

Catch the yellow **Rare** version and use it from your inventory to register it. Legendary and Unique versions do not count. After registering all six, return to Shi Yugong.

### Fractured Peaks

Travel southeast from Kyovashad to **Yelesna**, then fish from the bridge on the east side of town. **Marowen is in Scosglen**, not Fractured Peaks.

## Trawghll Murloc Pet

**Trawghll** is a Murloc pet reportedly obtained from the Mythic **Gurgling Bag of Rubbish** while fishing.

- It can reportedly drop while fishing in any region.
- There is no confirmed best location.
- Completing the fish collection is not required.
- The drop is extremely rare.

## How It Works

- Checks for the fishing-state icon every 100 milliseconds.
- Watches for the bite icon while fishing is active.
- Presses the configured reel key once when a bite is detected.
- Presses `E` and clicks the saved Fishing position when it needs to cast again.
- Uses cooldowns and detection latches to prevent repeated actions.
- Displays the current state, reel key, and hotkeys in a tooltip.

## Troubleshooting

### Icons are not detected

- Use borderless-windowed mode.
- The included searches were captured at `2560 × 1440`. Other resolutions or UI scales may require new captures.
- Match the hotbar layout shown in the demonstration.
- Disable HDR, overlays, and color filters.
- Run the script as administrator if Diablo IV is also running as administrator.
- Recapture the icons with `engine\graphicsearch_gui.ahk` if needed.

### The casting click lands in the wrong place

Press `F10`, press `E` to open the Action Wheel, then click Fishing to save its new position. Repeat this after changing the resolution, UI scale, window, or monitor.

### Keyboard actions do not reach the game

Run Diablo IV and the script at the same privilege level. If the game runs as administrator, run the script as administrator.

### Pause or quit

Press `F8` and wait for **FISHING PAUSED** to appear. A short action already in progress may finish first. Press `Esc` to quit immediately.

## Disclaimer

This is an unofficial community project and is not affiliated with or endorsed by Blizzard Entertainment. Automation may be restricted by a game's terms or rules. You are responsible for deciding whether and where to use this script.

## License

Diablo IV Fishing Buddy is licensed under the MIT License. See [LICENSE](LICENSE) for the complete text.

GraphicSearch is a third-party dependency with its own license. Preserve its original copyright and license notices when redistributing its files.