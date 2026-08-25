# Diablo IV Fishing Buddy

An AutoHotkey v1 script that uses GraphicSearch to detect the Diablo IV fishing state and bite indicator. It can cast at a saved mouse position, reel in a fish with a configurable keyboard key, and pause or resume through global hotkeys.

This script will help you get your fishing achievements in Diablo IV completed.

Copyright (c) 2026 SuperMilkers. Released under the MIT License.

## Demonstration

![Diablo IV Auto Fishing demonstration](assets/d4_fishing_buddy_AHK.gif)

## Community

Join us on Discord for help, updates, and discussion: [https://discord.gg/gvgbacUHcN](https://discord.gg/gvgbacUHcN)

## Disclaimer

This is an unofficial community project. It is not affiliated with or endorsed by Blizzard Entertainment. Automation may be restricted by a game's terms or rules. You are responsible for deciding whether and where to use this script.

## Windows requirements

- Windows 10 or Windows 11
- AutoHotkey v1.1
- `export.ahk` from [GraphicSearch](https://github.com/Chunjee/graphicsearch.ahk)
- Diablo IV running in borderless-windowed mode for reliable screen capture

AutoHotkey v1 and v2 can be installed together. The script contains `#Requires AutoHotkey v1.1`, which tells the AutoHotkey launcher to select v1.

## AutoHotkey requirement

This script requires **AutoHotkey v1.1.37.02**. AutoHotkey v2 is not compatible.

[Download AutoHotkey v1.1.37.02 for Windows](https://www.autohotkey.com/download/1.1/AutoHotkey_1.1.37.02_setup.exe)

After installing it, double-click `d4_fishing.ahk` to run the script.

## Folder structure

Keep the files arranged as follows:

```text
d4-fishing-buddy_AHK\
|-- d4_fishing.ahk
|-- LICENSE
|-- README.md
`-- engine\
    |-- export.ahk
    `-- graphicsearch_gui.ahk
```

The script should contain this include line:

```ahk
#Include %A_ScriptDir%\engine\export.ahk
```

## Installation

1. Install AutoHotkey v1.1 on Windows.
2. Download or copy the project folder to your computer.
3. Confirm that `export.ahk` is inside the `engine` folder.
4. Start Diablo IV and use the resolution and UI scale at which the GraphicSearch images were captured (2560 × 1440 pixels).
5. Run `d4_fishing.ahk`.

If Windows launches the script with the wrong interpreter, run it explicitly with AutoHotkey v1:

```bat
"C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU64.exe" "C:\path\to\d4_fishing.ahk"
```

Adjust the paths if AutoHotkey or the project is installed elsewhere.

## Gameplay notes

- Fish on a low difficulty, such as Normal.

- Your character must be facing fishable water.

- Use your mousewheel and zoom all the way in on your character.

- Equip some Thorns so nearby enemies, or enemies pulled up while fishing, damage themselves when they attack you.

- If **Diablo reconnecting** appears in the upper-left corner, fishing may be unavailable until the reconnecting state clears.

## First-time setup

1. Launch the script.
2. Read and close the setup message.
3. Move the mouse to the location where the game should click to cast.
4. Left-click once. The setup click is blocked from reaching the game; it only saves the screen coordinates.
5. The script begins monitoring the fishing state.
6. Confirm that the status tooltip reports `FISHING ACTIVE` while your character is fishing.

When the bite icon is detected, the script presses the configured reel key once. The default reel key is `5`.

## Hotkeys

| Hotkey | Action |
| --- | --- |
| `F8` | Pause or resume the automation |
| `F10` | Choose a new casting click position |
| `F11` | Change the reel key, then press the desired replacement key |
| `Esc` | Quit the script |

The reel-key selector supports one keyboard key at a time, including letters, numbers, arrow keys, numpad keys, `Space`, `Enter`, `Tab`, and most function keys. It does not support key combinations, mouse buttons, or controller buttons. Do not select `F8`, `F10`, `F11`, or `Esc`, because they are reserved by the script.

## Normal operation

- The script first verifies that the fishing-state icon is present.
- While fishing is active, it checks for the bite icon every 100 milliseconds.
- When the bite icon appears, it presses the configured reel key once.
- When fishing is no longer active, it presses `E`, moves the mouse to the saved casting position, and left-clicks.
- Cooldowns and detection latches prevent repeated reel or cast actions from the same event.
- The status tooltip always shows the current state, reel key, and available hotkeys.

## Troubleshooting

### The script reports an `#Include` error

Confirm that the following file exists:

```text
engine\export.ahk
```

Also confirm that the script uses:

```ahk
#Include %A_ScriptDir%\engine\export.ahk
```

### The script runs but does not detect an icon

- Run Diablo IV in borderless-windowed mode.
- Keep the same game resolution, Windows display scaling, and in-game UI scale used when the queries were captured.
- Disable HDR if the captured colors do not match during detection.
- Run the script as administrator if the game is running as administrator.
- Verify that no overlays, filters, or color-adjustment software are changing the icon.
- Recapture the icon with `engine\graphicsearch_gui.ahk` if the UI appearance changes.

### AutoHotkey opens help instead of running the script

Opening `AutoHotkeyU64.exe` by itself opens the help documentation. Double-click the `.ahk` script or pass the script path to the v1 executable as shown in the Installation section.

### The casting click lands in the wrong place

Press `F10`, move the pointer to the correct casting location, and left-click to save the new position. Reconfigure the position after changing resolution, window size, monitor, or UI scale.

### Keyboard actions do not reach the game

Run the script and game at the same privilege level. If Diablo IV is running as administrator, run the script as administrator as well.

### Stop the script immediately

Press `Esc`. You can also right-click the AutoHotkey tray icon and select **Exit**.

## License

Diablo IV Auto Fishing is licensed under the MIT License. See [LICENSE](LICENSE) for the complete license text.

GraphicSearch is a third-party dependency with its own license. Preserve its original copyright and license notices when redistributing files from that project.
