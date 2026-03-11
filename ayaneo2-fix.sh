#!/bin/bash
# =====================================================
# AYANEO 2 DISPLAY FIX FOR STEAMOS
# =====================================================
# Fix for image retention effect on Ayaneo 2 OLED display
# 
# Author: Adapted for the community
# Version: 1.2 (fixed resolution for Ayaneo 2)
# =====================================================

# Colors for nice output (optional)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Constants for Ayaneo 2
DISPLAY_NAME="eDP"
DISPLAY_WIDTH="1920"
DISPLAY_HEIGHT="1200"

# Function to check if zenity is installed
check_zenity() {
    if ! command -v zenity &> /dev/null; then
        echo -e "${YELLOW}Zenity not found. Installing...${NC}"
        sudo pacman -Rdd zenity 2>/dev/null || true
        sudo pacman -Sy --noconfirm zenity-gtk3
    fi
}

# Function to check if xterm is installed (for terminal display in GUI mode)
check_xterm() {
    if ! command -v xterm &> /dev/null; then
        echo -e "${YELLOW}xterm not found. Installing...${NC}"
        sudo pacman -Sy --noconfirm xterm
    fi
}

# Function to create 60 Hz mode for 1920x1200
create_60hz_mode() {
    echo -e "${BLUE}Creating ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}@60 Hz mode...${NC}"
    
    # Get mode modeline via cvt for 1920x1200 (Ayaneo 2 standard resolution)
    MODE_LINE=$(cvt ${DISPLAY_WIDTH} ${DISPLAY_HEIGHT} 60 | grep Modeline | sed 's/Modeline //')
    
    # Extract mode name and parameters
    MODE_NAME=$(echo "$MODE_LINE" | awk '{print $1}' | tr -d '"')
    MODE_PARAMS=$(echo "$MODE_LINE" | cut -d' ' -f2-)
    
    echo -e "${BLUE}Mode name: $MODE_NAME${NC}"
    echo -e "${BLUE}Parameters: $MODE_PARAMS${NC}"
    
    # Check if mode already exists
    EXISTING=$(xrandr | grep -F "$MODE_NAME" 2>/dev/null)
    
    if [ -z "$EXISTING" ]; then
        # Create new mode
        xrandr --newmode "$MODE_NAME" $MODE_PARAMS
        
        # Add mode to eDP output
        xrandr --addmode "$DISPLAY_NAME" "$MODE_NAME"
        echo -e "${GREEN}✓ Mode created${NC}"
    else
        echo -e "${GREEN}✓ Mode already exists${NC}"
    fi
    
    echo "$MODE_NAME"
}

# Function to apply display fixes
apply_display_fixes() {
    echo -e "${BLUE}Applying display settings...${NC}"
    
    # Disable DPMS (Display Power Management Signaling)
    xset dpms force on
    xset s off
    xset -dpms
    
    # Set high GPU performance
    if [ -f /sys/class/drm/card0/device/power_dpm_force_performance_level ]; then
        echo "high" | sudo tee /sys/class/drm/card0/device/power_dpm_force_performance_level > /dev/null
    fi
    
    # Force display refresh
    xrandr --output "$DISPLAY_NAME" --auto
    
    # Additional fixes for Ayaneo 2
    if [ -f /sys/module/amdgpu/parameters/dcdebugmask ]; then
        echo 0x00000 | sudo tee /sys/module/amdgpu/parameters/dcdebugmask > /dev/null 2>&1 || true
    fi
    
    echo -e "${GREEN}✓ Display settings applied${NC}"
}

# Function to apply CPU fixes
apply_cpu_fixes() {
    echo -e "${BLUE}Applying CPU settings...${NC}"
    
    # Set performance governor for all CPU cores
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        if [ -f "$cpu" ]; then
            echo "performance" | sudo tee "$cpu" > /dev/null 2>&1
        fi
    done
    
    echo -e "${GREEN}✓ CPU settings applied${NC}"
}

# Function to reset settings
reset_settings() {
    echo -e "${BLUE}Resetting settings to auto mode...${NC}"
    
    # Restore auto mode for GPU
    if [ -f /sys/class/drm/card0/device/power_dpm_force_performance_level ]; then
        echo "auto" | sudo tee /sys/class/drm/card0/device/power_dpm_force_performance_level > /dev/null
    fi
    
    # Restore auto mode for CPU
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        if [ -f "$cpu" ]; then
            echo "powersave" | sudo tee "$cpu" > /dev/null 2>&1
        fi
    done
    
    # Enable DPMS back
    xset dpms 0 0 0
    xset s on
    xset +dpms
    
    echo -e "${GREEN}✓ Settings reset${NC}"
}

# Function to show current settings
show_status() {
    echo -e "${BLUE}CURRENT SETTINGS:${NC}"
    echo "================================"
    
    # Display settings
    echo -e "${YELLOW}DISPLAY (${DISPLAY_NAME}):${NC}"
    if [ -f /sys/class/drm/card0/device/power_dpm_force_performance_level ]; then
        LEVEL=$(cat /sys/class/drm/card0/device/power_dpm_force_performance_level)
        echo "  GPU mode: $LEVEL"
    fi
    
    # Current mode and refresh rate
    if command -v xrandr &> /dev/null; then
        CURRENT=$(xrandr --query | grep -A1 "$DISPLAY_NAME connected" | tail -1)
        echo "  Current mode: $CURRENT"
        
        # Show all available modes
        echo "  Available modes:"
        xrandr | grep -A20 "$DISPLAY_NAME connected" | grep -E "[0-9]+x[0-9]+" | head -5 | while read line; do
            echo "    $line"
        done
    fi
    
    # CPU settings
    echo -e "${YELLOW}CPU:${NC}"
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
        GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
        echo "  CPU mode: $GOV"
    fi
    
    # Current CPU frequency
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq ]; then
        CUR_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
        echo "  Current frequency: $((CUR_FREQ/1000)) MHz"
    fi
    
    # AMDGPU boot parameters
    echo -e "${YELLOW}AMDGPU PARAMETERS:${NC}"
    if grep -q "amdgpu" /proc/cmdline; then
        echo "  $(cat /proc/cmdline | grep -o "amdgpu[^ ]*" | tr '\n' ' ')"
    fi
    
    echo "================================"
}

# Function to set 60 Hz (FIXED FOR 1920x1200)
set_60hz() {
    echo -e "${BLUE}Setting 60 Hz for ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}...${NC}"
    
    # Create 60 Hz mode
    MODE_NAME=$(create_60hz_mode)
    
    if [ $? -eq 0 ] && [ -n "$MODE_NAME" ]; then
        # Apply the mode
        xrandr --output "$DISPLAY_NAME" --mode "$MODE_NAME"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Refresh rate set to 60 Hz (mode $MODE_NAME)${NC}"
            echo -e "${YELLOW}Tip: 60 Hz reduces panel heat and decreases image retention${NC}"
        else
            echo -e "${RED}✗ Failed to apply mode${NC}"
        fi
    else
        echo -e "${RED}✗ Failed to create 60 Hz mode${NC}"
        # Try to find existing 60 Hz mode
        echo -e "${YELLOW}Looking for existing 60 Hz mode...${NC}"
        
        # Look for mode with 1920x1200 resolution and 60 Hz refresh rate
        EXISTING_MODE=$(xrandr | grep -E "${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}.*60\.00" | awk '{print $1}')
        
        if [ -n "$EXISTING_MODE" ]; then
            echo -e "${GREEN}Found mode: $EXISTING_MODE${NC}"
            xrandr --output "$DISPLAY_NAME" --mode "$EXISTING_MODE"
            echo -e "${GREEN}✓ Refresh rate set to 60 Hz${NC}"
        else
            echo -e "${RED}✗ Failed to set 60 Hz${NC}"
            echo -e "${YELLOW}Available modes:${NC}"
            xrandr | grep -A5 "$DISPLAY_NAME"
        fi
    fi
}

# Function to create systemd service
create_service() {
    echo -e "${BLUE}Creating systemd service for automatic startup...${NC}"
    
    # Get script path
    SCRIPT_PATH=$(readlink -f "$0")
    
    sudo bash -c "cat > /etc/systemd/system/ayaneo-display-fix.service << EOF
[Unit]
Description=AyaNeo Display Fix
After=multi-user.target

[Service]
Type=oneshot
ExecStart=$SCRIPT_PATH --apply-display
User=root

[Install]
WantedBy=multi-user.target
EOF"

    sudo systemctl daemon-reload
    echo -e "${GREEN}✓ Service created${NC}"
    echo -e "${YELLOW}To enable autostart, run:${NC}"
    echo "  sudo systemctl enable ayaneo-display-fix.service"
}

# Function for interactive menu (if zenity is available)
show_menu() {
    check_zenity
    check_xterm
    
    while true; do
        CHOICE=$(zenity --list \
            --title="AYANEO 2 Display Fix (1920x1200)" \
            --text="Choose action for Ayaneo 2:" \
            --column="Option" \
            --width=750 \
            --height=450 \
            "🎬 DISPLAY ONLY (fix image retention)" \
            "⚡ CPU ONLY (maximum performance)" \
            "🔄 DISPLAY + CPU (both modes)" \
            "📊 CURRENT SETTINGS" \
            "🎯 Set 60 Hz (1920x1200) [RECOMMENDED]" \
            "🌡️ RESET (restore auto mode)" \
            "⚙️ Create systemd service" \
            "❌ Exit")
        
        case $CHOICE in
            "🎬 DISPLAY ONLY (fix image retention)")
                apply_display_fixes
                zenity --info --text="✅ Display settings applied!\n\nRecommendations for Ayaneo 2:\n• Brightness 70-80%\n• Use 60 Hz to reduce heat\n• Don't leave static images for long periods" --width=450
                ;;
            "⚡ CPU ONLY (maximum performance)")
                apply_cpu_fixes
                zenity --info --text="✅ CPU settings applied!\n\nCPU is now running in maximum performance mode" --width=400
                ;;
            "🔄 DISPLAY + CPU (both modes)")
                apply_display_fixes
                apply_cpu_fixes
                zenity --info --text="✅ All settings applied!\n\n• Display: power saving disabled\n• CPU: performance mode" --width=400
                ;;
            "📊 CURRENT SETTINGS")
                STATUS=$(show_status 2>&1)
                zenity --info --text="$STATUS" --width=600 --height=500
                ;;
            "🎯 Set 60 Hz (1920x1200) [RECOMMENDED]")
                # Run in terminal to show mode creation process
                xterm -geometry 80x20 -e "bash -c '$0 --60hz; echo; echo \"Press Enter to continue...\"; read'"
                zenity --info --text="✅ Operation completed.\nCheck terminal for details." --width=300
                ;;
            "🌡️ RESET (restore auto mode)")
                reset_settings
                zenity --info --text="✅ All settings reset to auto mode" --width=300
                ;;
            "⚙️ Create systemd service")
                create_service
                zenity --info --text="✅ Service created!\n\nTo enable, run in terminal:\nsudo systemctl enable ayaneo-display-fix.service" --width=400
                ;;
            "❌ Exit"|"")
                exit 0
                ;;
        esac
    done
}

# Function to show help
show_help() {
    echo "AYANEO 2 DISPLAY FIX (1920x1200)"
    echo "================================"
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  --apply-display    Apply display fixes only"
    echo "  --apply-cpu        Apply CPU fixes only"
    echo "  --apply-all        Apply all fixes"
    echo "  --reset           Reset all settings"
    echo "  --status          Show current settings"
    echo "  --60hz            Set 60 Hz for 1920x1200"
    echo "  --create-service  Create systemd service"
    echo "  --menu            Show graphical menu (default)"
    echo "  --help            Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 --menu                    # Graphical menu"
    echo "  $0 --apply-display           # Display only"
    echo "  $0 --60hz                    # Set 60 Hz"
    echo "  sudo $0 --create-service     # Create autostart service"
}

# =====================================================
# MAIN
# =====================================================

# Check if script is run with root rights for certain operations
if [ "$EUID" -ne 0 ]; then
    # Check if root rights are needed for current operation
    case "$1" in
        --create-service|--apply-display|--apply-cpu|--apply-all|--reset)
            echo -e "${YELLOW}Some operations require root privileges. Requesting password...${NC}"
            sudo "$0" "$@"
            exit $?
            ;;
    esac
fi

# Process command line arguments
if [ $# -eq 0 ]; then
    # No arguments - show menu (if GUI available) or help
    if [ -n "$DISPLAY" ]; then
        show_menu
    else
        show_help
    fi
else
    case "$1" in
        --apply-display)
            apply_display_fixes
            ;;
        --apply-cpu)
            apply_cpu_fixes
            ;;
        --apply-all)
            apply_display_fixes
            apply_cpu_fixes
            ;;
        --reset)
            reset_settings
            ;;
        --status)
            show_status
            ;;
        --60hz)
            set_60hz
            ;;
        --create-service)
            create_service
            ;;
        --menu)
            show_menu
            ;;
        --help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
fi

exit 0
