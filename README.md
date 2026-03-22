<div align="center">

```
╔══════════════════════════════════════════════════╗
║      ROBLOX RESOLUTION SWITCHER   v3.0           ║
║  by YOUR_USERNAME                                ║
╚══════════════════════════════════════════════════╝
```

![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D4?style=flat-square&logo=windows)
![PowerShell](https://img.shields.io/badge/PowerShell-5.0+-5391FE?style=flat-square&logo=powershell)
![No Install](https://img.shields.io/badge/no_install-required-00C853?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-orange?style=flat-square)

**Automatically switches your display resolution when Roblox is focused.**  
**Restores it instantly on Alt+Tab or when you close the game.**

[**Download**](#-download) · [**How it works**](#-how-it-works) · [**Usage**](#-usage) · [**FAQ**](#-faq)

</div>

---

## ✦ What it does

Most Roblox players who compete or stream use a **4:3 stretched resolution** for a wider field of view or better performance — but switching manually every time you open the game is annoying.

This tool does it automatically:

| State | Resolution |
|---|---|
| 🟢 Roblox window **focused** | Your target (e.g. `1280x1024`) |
| 🟡 Roblox window **in background** | Your normal Windows resolution |
| 🔴 Roblox **closed** | Your normal Windows resolution |

Your Windows desktop is **never permanently changed** — everything restores the moment you Alt+Tab.

---

## ✦ Preview

```
====================================================
    ROBLOX RESOLUTION SWITCHER   v3.0
====================================================
    by YOUR_USERNAME
    github.com/YOUR_USERNAME/roblox-resolution-switcher
====================================================

  Current Windows resolution: 1920 x 1080

  ----------------------------------------------------
  RESOLUTION PRESETS
  ----------------------------------------------------
   [1]  1280 x 1024  (5:4)
   [2]  1280 x  960  (4:3)
   [3]  1024 x  768  (4:3)
   [4]   800 x  600  (4:3)
   [5]  1920 x 1080  (16:9)
   [6]  1600 x  900  (16:9)
   [7]  1366 x  768  (16:9)
   [8]  2560 x 1440  (16:9)
  ----------------------------------------------------
   [C]  Custom resolution
   [Q]  Quit
  ----------------------------------------------------

  Select:
```

---

## ✦ Download

1. Click **Code → Download ZIP** or clone:
```bash
git clone https://github.com/YOUR_USERNAME/roblox-resolution-switcher
```

2. Extract both files to the **same folder**:
```
📁 roblox-resolution-switcher/
 ├── START.bat
 └── RobloxResolution.ps1
```

---

## ✦ Usage

### First time only — allow PowerShell scripts
Open **PowerShell as Administrator** and run:
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### Every time
1. Double-click **`START.bat`**
2. Pick a resolution preset `[1–8]` or `[C]` for custom
3. Set check interval (default: `1s`)
4. Launch Roblox — resolution switches automatically
5. Press `Ctrl+C` to stop, `[Q]` to quit

---

## ✦ How it works

The script uses Windows API to:
1. **Detect** which process owns the foreground window (`GetForegroundWindow` + `GetWindowThreadProcessId`)
2. **Compare** it against known Roblox process names (`RobloxPlayerBeta`, `RobloxPlayer`, `Roblox`)
3. **Switch** display resolution via `ChangeDisplaySettings` only when Roblox is active
4. **Restore** your original resolution the moment Roblox loses focus or closes

No config files. No registry edits. No third-party software.

---

## ✦ Resolution presets

| Preset | Resolution | Aspect Ratio | Common use |
|--------|-----------|--------------|------------|
| 1 | 1280 × 1024 | 5:4 | Classic stretched |
| 2 | 1280 × 960  | 4:3 | Stretched |
| 3 | 1024 × 768  | 4:3 | Stretched |
| 4 | 800 × 600   | 4:3 | Low-res stretched |
| 5 | 1920 × 1080 | 16:9 | Native fullscreen |
| 6 | 1600 × 900  | 16:9 | Windowed |
| 7 | 1366 × 768  | 16:9 | Laptop native |
| 8 | 2560 × 1440 | 16:9 | 2K |

Or enter any custom resolution with `[C]`.

---

## ✦ Requirements

- Windows 10 or Windows 11
- PowerShell 5.0+ *(built into Windows — nothing to install)*
- Roblox installed via the official launcher

---

## ✦ FAQ

**Resolution doesn't change when I open Roblox?**  
Make sure the script is running before you open Roblox. Also verify your monitor actually supports the target resolution.

**I get an error about execution policy.**  
Run this once in PowerShell as Administrator:
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

**Will this get me banned?**  
No. This tool only changes your Windows display settings — it does not interact with or modify the Roblox client in any way.

**Can I use this for other games?**  
The script specifically checks for Roblox processes. You can edit `$RobloxProcessNames` in the `.ps1` file to add other games.

**My resolution didn't restore after closing.**  
Press `Ctrl+C` in the script window to force restore, or change it manually via Windows Display Settings.

---

## ✦ License

MIT — free to use, modify and distribute.

---

<div align="center">

made by **YOUR_USERNAME**  
if this helped you, drop a ⭐

</div>
