#!/usr/bin/env bash

echo
echo "Hardware Summary"
echo "----------------"

if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi

echo
echo "Battery"
echo "-------"

if command -v upower >/dev/null 2>&1; then
    BAT_DEV=$(upower -e 2>/dev/null | grep -i BAT | head -n 1)
    if [ -n "$BAT_DEV" ]; then
        upower -i "$BAT_DEV"
    else
        echo "No battery device found."
    fi
else
    echo "upower not installed."
fi

echo
echo "Temperatures"
echo "------------"

if command -v sensors >/dev/null 2>&1; then
    sensors
else
    echo "lm-sensors not configured or installed."
fi

echo
echo "=========================================="
echo "Manual Tasks"
echo "=========================================="

echo "[ ] Login to Brave"
echo "[ ] Setup Brave Sync"
echo "[ ] Login to Bitwarden"
echo "[ ] Install Dash to Dock"
echo "[ ] Run fprintd-enroll"
echo "[ ] Configure OpenBangla"
echo "[ ] Restore wallpaper"

echo
echo "Finished."