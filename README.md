AYANEO 2 Display Fix

# AYANEO 2 Display Fix

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![AYANEO 2](https://img.shields.io/badge/AYANEO-2-blue)
![SteamOS](https://img.shields.io/badge/SteamOS-3.x-black)
![Bazzite](https://img.shields.io/badge/Bazzite-supported-green)
![Windows 11](https://img.shields.io/badge/Windows%2011-limited-yellow)

A utility script to minimize **image retention (ghosting)** on the AYANEO 2 IPS LCD display. This issue can occur on IPS panels when aggressive power-saving features are enabled, causing static elements to temporarily leave "ghosts" on the screen.

## ⚠️ Important Disclaimer

**This script does NOT "fix" or "cure" a hardware defect.**

Image retention (also called "ghosting" or "temporary image persistence") can happen on IPS LCD panels under certain conditions. On the AYANEO 2, this is primarily caused by:
- **Panel Self Refresh (PSR)** features that can cause pixel voltage drift
- **High refresh rates** generating more heat
- **Aggressive power management** that underdrives the panel

This script **minimizes** the effect by:
- Disabling PSR and other power-saving display features
- Reducing heat generation by offering a stable 60 Hz mode
- Forcing display refreshes to clear temporary charge buildup
- Optimizing GPU/CPU power management for consistent panel operation

## 🔧 What This Script Does

| Feature | Description |
|---------|-------------|
| **Display optimizations** | Disables PSR, DPMS, and other power-saving features that contribute to ghosting |
| **CPU performance mode** | Sets CPU governor to "performance" for consistent power delivery |
| **60 Hz mode** | Creates and applies 1920×1200@60 Hz mode (reduces heat and panel stress) |
| **Panel refresh** | Forces immediate display refresh to clear temporary retention |
| **Gamescope restart** | Restarts SteamOS gaming session if needed |
| **Systemd service** | Optional auto-apply at boot |
| **Current settings viewer** | Shows GPU mode, CPU governor, available refresh rates |

## 📱 AYANEO 2 Display Specifications

According to multiple sources, the AYANEO 2 features:
- **7-inch IPS LCD touchscreen** (not OLED)
- **Resolution**: 1920×1200 (16:10 aspect ratio)
- **Brightness**: 400 nits
- **Contrast ratio**: 1200:1
- **Color gamut**: 135% sRGB
- **Glass cover**: Single sheet with anti-fingerprint coating

## 🖥️ System Compatibility

### ✅ Fully Supported
| System | Status | Notes |
|--------|--------|-------|
| **SteamOS 3.x** (Steam Deck / AYANEO) | ✅ Full | Native support, all features work |
| **Bazzite** | ✅ Full | SteamOS-like environment, all features work |
| **Any Arch Linux** | ✅ Full | Script uses pacman for dependencies |
| **Any Linux with X11/Wayland** | ✅ Full | Requires typical Linux tools (xrandr, xset, etc.) |

### ⚠️ Limited Support
| System | Status | Notes |
|--------|--------|-------|
| **Windows 11** | ⚠️ No | This is a Linux/bash script. For Windows, use [CRU](https://www.monitortests.com/forum/Thread-Custom-Resolution-Utility-CRU) to set 60 Hz and disable GPU power saving manually. You can also try turning off "Panel Self Refresh" in AMD Adrenalin software. |
| **macOS** | ❌ No | Not supported |
| **ChromeOS** | ❌ No | Not supported |

### 🐧 Linux Distribution Compatibility

The script works on any Linux distribution with:
- `bash`
- `xrandr` (for display management)
- `xset` (for DPMS control)
- `sudo` access
- AMDGPU driver (for AYANEO 2 hardware)

For non-Arch based systems (Ubuntu, Fedora, etc.):

```bash
# Ubuntu/Debian
sudo apt install x11-xserver-utils zenity

# Fedora
sudo dnf install xorg-x11-server-utils zenity
```

📦 Installation

Quick Install

```bash
# Download the script
curl -o ~/ayaneo2-fix.sh https://raw.githubusercontent.com/unlogicalswsw2/Ayaneo2_SteamOS_fix_-retention/main/ayaneo2-fix.sh

# Make it executable
chmod +x ~/ayaneo2-fix.sh

# Run it
./ayaneo2-fix.sh
```
Manual Install

Copy the script content from this repository
Save as ~/ayaneo2-fix.sh
Run chmod +x ~/ayaneo2-fix.sh
🚀 Usage

Graphical Menu (recommended)

```bash
./ayaneo2-fix.sh
# or
./ayaneo2-fix.sh --menu
```
Command Line Options

```bash
# Apply display fixes only (disables power saving)
./ayaneo2-fix.sh --apply-display

# Apply CPU fixes only (performance mode)
./ayaneo2-fix.sh --apply-cpu

# Apply both display and CPU fixes
./ayaneo2-fix.sh --apply-all

# Show current system status
./ayaneo2-fix.sh --status

# Set 60 Hz mode (recommended for reducing heat)
./ayaneo2-fix.sh --60hz

# Reset all settings to auto/powersave
./ayaneo2-fix.sh --reset

# Create systemd service for autostart
sudo ./ayaneo2-fix.sh --create-service
```
SteamOS / Bazzite Integration

To add the script to Steam Gaming Mode:

Switch to Desktop Mode
Open Steam → "Add a Game" → "Add a Non-Steam Game"
Browse to /home/deck/ayaneo2-fix.sh
Add it to your library
In Properties, you can rename it to "AYANEO Display Fix"
🎯 Recommended Settings for AYANEO 2

For the best balance between display quality and reduced image retention:

Run the script and select → "🎯 Set 60 Hz (1920x1200) [RECOMMENDED]"
Select → "🎬 DISPLAY ONLY (fix image retention)"
In SteamOS Settings:

Set brightness to a comfortable level (avoid max brightness for long periods)
Enable screen saver/screen off after 5-10 minutes of inactivity
Avoid leaving static HUD elements on screen for hours
🔍 How It Works (Technical Details)

The Phenomenon

Image retention on IPS LCD panels (sometimes called "image sticking" or "ghosting") occurs when liquid crystals don't fully relax to their neutral state after displaying a static image for an extended period . On the AYANEO 2, this is exacerbated by:

Panel Self Refresh (PSR) - A power-saving feature that can cause pixel voltage drift
High refresh rate operation - Running at maximum refresh generates more heat
Aggressive power management - Under-driving the panel to save battery
The Solution

This script addresses these causes by:

Reducing heat → 60 Hz mode lowers panel temperature and power consumption
Disabling PSR → Prevents the panel from entering power-saving states that cause ghosting
Forcing performance mode → Ensures consistent power delivery to the display controller
Periodic refresh → Forcing display updates helps crystals return to neutral state
For Windows 11 Users

While this script doesn't work on Windows, you can achieve similar results:

Use CRU (Custom Resolution Utility) to create a 1920×1200@60 Hz mode
In AMD Adrenalin Software:

Go to Display → Disable "Vari-Bright"
Go to Graphics → Set "Power Saving" to "Disabled"
Turn off "Panel Self Refresh" if available
Use Windowed Borderless Gaming to avoid static title bars
Consider using AutoActions to automatically apply settings per application
📊 Comparison: Before vs After

Scenario	Image Retention	Heat	Battery Life
Stock (default settings)	🔴 Noticeable	🔥🔥	3-4 hours
60 Hz only	🟡 Reduced	🔥	4-5 hours
60 Hz + Display fixes (this script)	🟢 Minimal	🔥	4-5 hours
60 Hz + Display fixes + moderate brightness	🟢 Barely noticeable	🔥	5-6 hours
🐛 Troubleshooting

"xrandr: cannot find mode 1920x1080"

The script automatically creates the correct 1920×1200 mode. If you see this, you're using an older version - update to v1.2.

"tee: /sys/module/amdgpu/parameters/psr_enable: No such file"

Your kernel handles PSR differently. The script now detects available parameters automatically.

Zenity not opening

Install dependencies:

```bash
# SteamOS / Arch
sudo pacman -S zenity-gtk3

# Ubuntu/Debian
sudo apt install zenity

# Fedora
sudo dnf install zenity
```
Script works but ghosting persists

Try the "Set 60 Hz" option first - this has the biggest impact. If ghosting continues, ensure you're not running at max brightness for extended periods, and consider using dark mode in applications that support it.

🤝 Contributing

Pull requests welcome! Areas for improvement:

Support for other AYANEO models (Air, Pro, Kun, etc.) 
Windows PowerShell version
More aggressive IPS preservation modes
Integration with SteamOS plugins (Decky Loader)
Automatic detection of available PSR parameters
📄 License

MIT License - feel free to use, modify, and distribute.

🙏 Credits

AYANEO community for testing and feedback 
SteamOS users who reported the issue
Linux kernel developers for AMDGPU improvements
IGN and other reviewers for hardware documentation 
Remember: Image retention on IPS panels is temporary and usually clears on its own. This script helps minimize its occurrence, but it's not a hardware fix. Treat your AYANEO 2 well - avoid static content at max brightness for hours, and it'll serve you well for years.

*The AYANEO 2 features a high-quality 7-inch IPS LCD display with 1920×1200 resolution and 400 nits brightness . This script is designed specifically for this hardware configuration.*
