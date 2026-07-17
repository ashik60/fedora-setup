#!/usr/bin/env bash

echo
echo "Hardware Summary"
echo "----------------"

fastfetch

echo
echo "Battery"
echo "-------"

upower -i $(upower -e | grep BAT)

echo
echo "Temperatures"
echo "------------"

sensors

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
echo "[ ] Restore fonts"
echo "[ ] Restore wallpaper"

echo
echo "Finished."