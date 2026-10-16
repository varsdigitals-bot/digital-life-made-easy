# Claude Dictation Hotkey for Windows

**Press Ctrl + Win to start dictation in the Claude desktop app.** No hunting for the mic icon with your mouse.

Part of [VARS Digital: Digital Life Made Easy](../../).

- **Toggle mode (default):** press **Ctrl + Win** once and talk. Press **Enter** to finish, or Ctrl + Win again.
- **Hold mode (optional):** hold Ctrl + Win while you talk; release to finish.

## Why it keeps working when you resize the window

Quick fixes usually click fixed screen coordinates. Those miss as soon as the window is resized, the sidebar opens, or you're on the new-chat screen.

This script uses **Windows UI Automation**, the accessibility API built into Windows that screen readers use. It finds Claude's buttons **by name**, `Dictate` and `Finish dictation`, and presses them directly.

- Works at any window size, with the sidebar open or closed, and on the new-chat screen
- The mouse never moves; nothing gets clicked on screen
- No calibration
- **One readable file, no third-party libraries**: about 130 lines of AutoHotkey calling Windows' own UI Automation

## Requirements

- Windows 10 or 11
- [Claude desktop app](https://claude.ai/download)
- [AutoHotkey v2](https://www.autohotkey.com/) (installer or portable zip)

## Install

1. Install AutoHotkey v2.
2. Download [`ClaudeMic.ahk`](ClaudeMic.ahk) and double-click it. A green **H** icon appears in the system tray.
3. Optional, to start it with Windows: press `Win + R`, type `shell:startup`, and put a shortcut to `ClaudeMic.ahk` in that folder.

## Settings

Edit the block at the top of `ClaudeMic.ahk`, then right-click the tray icon and choose **Reload Script**.

| Setting | Default | What it does |
|---|---|---|
| `MODE` | `"toggle"` | `"toggle"`: press once to start; Enter or Ctrl + Win to finish. `"hold"`: talk while holding; release to finish. |
| `ACTIVATE` | `true` | Bring Claude to the front when you press the shortcut. |
| `BTN_START` / `BTN_FINISH` | `"Dictate"` / `"Finish dictation"` | Claude's button names. Update these if a Claude release renames them. |

## Self-test

```
AutoHotkey64.exe /ErrorStdOut ClaudeMic.ahk /test
```

This starts dictation, waits 1.5 s, finishes it, and prints `window=1 start=1 finish=1` on success.

## Limitations

- **Claude only.** Claude's dictation lives inside the Claude app and can't type into other programs. For other apps, Windows' own voice typing is `Win + H`.
- While the script runs, it takes over Ctrl + Win combos (e.g. `Ctrl + Win + ←/→` for switching virtual desktops).
- A Claude update that renames the buttons breaks it until `BTN_START` / `BTN_FINISH` are updated.

## Related projects

Want more features? These community tools use the same press-the-button-by-name approach:

- [AweGuider/Claude-Dictate-Hotkey](https://github.com/AweGuider/Claude-Dictate-Hotkey): tap or hold on one key, auto-stop after silence, an installer and a settings window.
- [nickrannikko-hub/Hey-Claude-](https://github.com/nickrannikko-hub/Hey-Claude-): a captions overlay, a "Hey Claude" wake word, Stream Deck buttons.

## License

MIT, © 2026 VARS Digital. Unofficial; not affiliated with or endorsed by Anthropic.
