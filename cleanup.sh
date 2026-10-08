#!/usr/bin/env bash

set -euo pipefail

if command -v dnf >/dev/null 2>&1; then
    echo "Cleaning DNF packages..."
    sudo dnf autoremove -y
    sudo dnf clean all
elif command -v apt-get >/dev/null 2>&1; then
    echo "Cleaning APT packages..."
    sudo apt-get autoremove -y
    sudo apt-get clean
fi

if command -v flatpak >/dev/null 2>&1; then
    echo "Cleaning unused Flatpaks..."
    flatpak uninstall --unused -y
fi