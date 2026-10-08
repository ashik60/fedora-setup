#!/usr/bin/env bash

echo "Applying GNOME preferences..."

gsettings set org.gnome.desktop.interface color-scheme prefer-dark

gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true

gsettings set org.gnome.desktop.interface clock-show-weekday true

gsettings set org.gnome.desktop.interface clock-show-seconds false

gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

echo "Done."