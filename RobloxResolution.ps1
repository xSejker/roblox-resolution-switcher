# ============================================================
#  RobloxResolution.ps1  v3.0
#  Run via START.bat
#  github.com/YOUR_USERNAME/roblox-resolution-switcher
# ============================================================

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class WinAPI {

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
    public struct DEVMODE {
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        public string dmDeviceName;
        public UInt16 dmSpecVersion;
        public UInt16 dmDriverVersion;
        public UInt16 dmSize;
        public UInt16 dmDriverExtra;
        public UInt32 dmFields;
        public Int32  dmPositionX;
        public Int32  dmPositionY;
        public UInt32 dmDisplayOrientation;
        public UInt32 dmDisplayFixedOutput;
        public Int16  dmColor;
        public Int16  dmDuplex;
        public Int16  dmYResolution;
        public Int16  dmTTOption;
        public Int16  dmCollate;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        public string dmFormName;
        public UInt16 dmLogPixels;
        public UInt32 dmBitsPerPel;
        public UInt32 dmPelsWidth;
        public UInt32 dmPelsHeight;
        public UInt32 dmDisplayFlags;
        public UInt32 dmDisplayFrequency;
        public UInt32 dmICMMethod;
        public UInt32 dmICMIntent;
        public UInt32 dmMediaType;
        public UInt32 dmDitherType;
        public UInt32 dmReserved1;
        public UInt32 dmReserved2;
        public UInt32 dmPanningWidth;
        public UInt32 dmPanningHeight;
    }

    [DllImport("user32.dll", CharSet = CharSet.Ansi)]
    public static extern bool EnumDisplaySettings(string device, int modeNum, ref DEVMODE dm);

    [DllImport("user32.dll")]
    public static extern int ChangeDisplaySettings(ref DEVMODE dm, uint flags);

    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr hwnd, out uint pid);

    public static DEVMODE GetCurrentSettings() {
        DEVMODE dm = new DEVMODE();
        dm.dmSize = (UInt16)Marshal.SizeOf(dm);
        EnumDisplaySettings(null, -1, ref dm);
        return dm;
    }

    public static int SetResolution(int width, int height) {
        DEVMODE dm = new DEVMODE();
        dm.dmSize = (UInt16)Marshal.SizeOf(dm);
        EnumDisplaySettings(null, -1, ref dm);
        dm.dmPelsWidth  = (UInt32)width;
        dm.dmPelsHeight = (UInt32)height;
        dm.dmFields     = 0x00080000 | 0x00100000;
        return ChangeDisplaySettings(ref dm, 0);
    }

    public static uint GetForegroundPid() {
        IntPtr hwnd = GetForegroundWindow();
        uint pid = 0;
        GetWindowThreadProcessId(hwnd, out pid);
        return pid;
    }
}
"@

$Presets = @(
    @{ Label = "1280 x 1024  (5:4) "; W = 1280; H = 1024 },
    @{ Label = "1280 x  960  (4:3) "; W = 1280; H =  960 },
    @{ Label = "1024 x  768  (4:3) "; W = 1024; H =  768 },
    @{ Label = " 800 x  600  (4:3) "; W =  800; H =  600 },
    @{ Label = "1920 x 1080  (16:9)"; W = 1920; H = 1080 },
    @{ Label = "1600 x  900  (16:9)"; W = 1600; H =  900 },
    @{ Label = "1366 x  768  (16:9)"; W = 1366; H =  768 },
    @{ Label = "2560 x 1440  (16:9)"; W = 2560; H = 1440 }
)

$RobloxProcessNames = @("RobloxPlayerBeta", "RobloxPlayer", "Roblox")

function Get-RobloxPids {
    $list = @()
    foreach ($name in $RobloxProcessNames) {
        Get-Process -Name $name -ErrorAction SilentlyContinue | ForEach-Object { $list += $_.Id }
    }
    return $list
}

function Is-RobloxRunning    { return ((Get-RobloxPids).Count -gt 0) }
function Is-RobloxForeground { return ((Get-RobloxPids) -contains [WinAPI]::GetForegroundPid()) }

function Set-Res {
    param([int]$W, [int]$H, [string]$Label)
    $r = [WinAPI]::SetResolution($W, $H)
    if ($r -eq 0 -or $r -eq -1) {
        Write-Host "  [$(Get-Date -Format 'HH:mm:ss')]  $Label" -ForegroundColor Green
        return $true
    }
    Write-Host "  [$(Get-Date -Format 'HH:mm:ss')]  FAILED code=$r (resolution not supported)" -ForegroundColor Red
    return $false
}

function Sep { param([string]$C="-",[int]$N=52)
    Write-Host ("  " + ($C * $N)) -ForegroundColor DarkGray
}

function Draw-Header {
    Clear-Host
    Write-Host ""
    Sep "=" 52
    Write-Host "    ROBLOX RESOLUTION SWITCHER   v3.0" -ForegroundColor Cyan
    Sep "=" 52
    Write-Host "    by YOUR_USERNAME" -ForegroundColor DarkGray
    Write-Host "    github.com/YOUR_USERNAME/roblox-resolution-switcher" -ForegroundColor DarkGray
    Sep "=" 52
    Write-Host ""
}

function Show-Menu {
    param([int]$OrigW, [int]$OrigH)
    Draw-Header
    Write-Host "  Current Windows resolution: " -NoNewline
    Write-Host "${OrigW} x ${OrigH}" -ForegroundColor Yellow
    Write-Host ""
    Sep "-" 52
    Write-Host "  RESOLUTION PRESETS" -ForegroundColor Cyan
    Sep "-" 52
    for ($i = 0; $i -lt $Presets.Count; $i++) {
        Write-Host "   [$($i+1)]  $($Presets[$i].Label)" -ForegroundColor White
    }
    Sep "-" 52
    Write-Host "   [C]  Custom resolution" -ForegroundColor Yellow
    Write-Host "   [Q]  Quit" -ForegroundColor Red
    Sep "-" 52
    Write-Host ""
    Write-Host "  Select: " -NoNewline -ForegroundColor Cyan
}

function Ask-Interval {
    Write-Host ""
    Write-Host "  Check interval in seconds [1-5, default=1]: " -NoNewline -ForegroundColor Cyan
    $raw = Read-Host
    if ($raw -match '^[0-9]+$') {
        $v = [int]$raw
        if ($v -ge 1 -and $v -le 5) { return $v }
    }
    return 1
}

function Start-Watcher {
    param([int]$W, [int]$H, [int]$OrigW, [int]$OrigH, [int]$Interval)
    Draw-Header
    Write-Host "  STATUS: RUNNING" -ForegroundColor Green
    Sep "-" 52
    Write-Host "  Windows base   :  ${OrigW} x ${OrigH}" -ForegroundColor DarkGray
    Write-Host "  Roblox target  :  ${W} x ${H}" -ForegroundColor Cyan
    Write-Host "  Interval       :  ${Interval}s" -ForegroundColor DarkGray
    Sep "-" 52
    Write-Host "  Switches when Roblox window is focused." -ForegroundColor DarkGray
    Write-Host "  Alt+Tab restores your normal resolution." -ForegroundColor DarkGray
    Sep "-" 52
    Write-Host "  Press Ctrl+C to stop and return to menu." -ForegroundColor Yellow
    Sep "-" 52
    Write-Host ""

    $robloxWasFg = $false
    $currentRes  = "orig"

    try {
        while ($true) {
            $running = Is-RobloxRunning
            $isFg    = $running -and (Is-RobloxForeground)

            if ($isFg -and -not $robloxWasFg) {
                Set-Res -W $W -H $H -Label "Roblox focused     -> ${W}x${H}" | Out-Null
                $currentRes  = "roblox"
                $robloxWasFg = $true
            }
            elseif (-not $isFg -and $robloxWasFg) {
                $lbl = if ($running) { "Roblox background  -> ${OrigW}x${OrigH}" } else { "Roblox closed      -> ${OrigW}x${OrigH}" }
                Set-Res -W $OrigW -H $OrigH -Label $lbl | Out-Null
                $currentRes  = "orig"
                $robloxWasFg = $false
            }

            Start-Sleep -Seconds $Interval
        }
    }
    finally {
        if ($currentRes -eq "roblox") {
            [WinAPI]::SetResolution($OrigW, $OrigH) | Out-Null
            Write-Host ""
            Write-Host "  Restored ${OrigW}x${OrigH}" -ForegroundColor Magenta
        }
        Write-Host ""
        Write-Host "  Press Enter to return to menu..." -ForegroundColor DarkGray
        Read-Host | Out-Null
    }
}

# ---- Main -------------------------------------------------------------------

$orig  = [WinAPI]::GetCurrentSettings()
$OrigW = [int]$orig.dmPelsWidth
$OrigH = [int]$orig.dmPelsHeight

$host.UI.RawUI.WindowTitle = "RobloxResolution v3.0"

while ($true) {
    Show-Menu -OrigW $OrigW -OrigH $OrigH
    $key = Read-Host

    if ($key -match '^[1-9]$') {
        $idx = [int]$key - 1
        if ($idx -lt $Presets.Count) {
            $p = $Presets[$idx]
            $iv = Ask-Interval
            Start-Watcher -W $p.W -H $p.H -OrigW $OrigW -OrigH $OrigH -Interval $iv
            continue
        }
    }

    if ($key -eq 'C' -or $key -eq 'c') {
        Write-Host ""
        Write-Host "  Width  : " -NoNewline -ForegroundColor Cyan
        $wRaw = Read-Host
        Write-Host "  Height : " -NoNewline -ForegroundColor Cyan
        $hRaw = Read-Host
        if ($wRaw -match '^[0-9]+$' -and $hRaw -match '^[0-9]+$') {
            $cW = [int]$wRaw
            $cH = [int]$hRaw
            if ($cW -ge 640 -and $cH -ge 480) {
                $iv = Ask-Interval
                Start-Watcher -W $cW -H $cH -OrigW $OrigW -OrigH $OrigH -Interval $iv
                continue
            }
        }
        Write-Host "  Invalid. Minimum 640x480." -ForegroundColor Red
        Start-Sleep -Seconds 2
        continue
    }

    if ($key -eq 'Q' -or $key -eq 'q') {
        Write-Host ""
        Write-Host "  Goodbye." -ForegroundColor DarkGray
        Write-Host ""
        break
    }

    Write-Host "  Invalid option." -ForegroundColor Red
    Start-Sleep -Seconds 1
}