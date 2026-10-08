#!/usr/bin/env bash

set -euo pipefail

if command -v dnf >/dev/null 2>&1; then
    echo "Upgrading DNF packages..."
    sudo dnf upgrade --refresh -y
elif command -v apt-get >/dev/null 2>&1; then
    echo "Upgrading APT packages..."
    sudo apt-get update -y
    sudo apt-get upgrade -y
fi

if command -v flatpak >/dev/null 2>&1; then
    echo "Updating Flatpaks..."
    flatpak update -y
fi