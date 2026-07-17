#!/usr/bin/env bash

set -uo pipefail

LOGFILE="install.log"

GREEN="\033[1;32m"
RED="\033[1;31m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

log() {
    echo -e "$1"
    echo -e "$(echo -e "$1" | sed 's/\x1b\[[0-9;]*m//g')" >> "$LOGFILE"
}

echo "" > "$LOGFILE"

log "${BLUE}"
log "======================================="
log " Fedora Personal Setup"
log "======================================="
log "${NC}"

#########################################
# Update
#########################################

log "${GREEN}Updating Fedora...${NC}"
sudo dnf upgrade -y

#########################################
# RPM Fusion
#########################################

if ! rpm -q rpmfusion-free-release >/dev/null 2>&1; then
    log "${GREEN}Installing RPM Fusion...${NC}"

    sudo dnf install -y \
    https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
else
    log "${YELLOW}RPM Fusion already installed.${NC}"
fi

#########################################
# DNF Packages
#########################################

log "${GREEN}Installing DNF packages...${NC}"

while read package
do
    [[ -z "$package" ]] && continue
    [[ "$package" =~ ^# ]] && continue

    if rpm -q "$package" >/dev/null 2>&1
    then
        log "${YELLOW}✓ $package already installed${NC}"
    else
        log "${BLUE}Installing $package${NC}"

        sudo dnf install -y "$package" \
            || log "${RED}Failed: $package${NC}"
    fi

done < dnf-packages.txt

#########################################
# Flatpak
#########################################

if ! rpm -q flatpak >/dev/null
then
    sudo dnf install -y flatpak
fi

flatpak remote-add --if-not-exists flathub \
https://flathub.org/repo/flathub.flatpakrepo

#########################################
# Flatpaks
#########################################

log "${GREEN}Installing Flatpaks...${NC}"

while read app
do

    [[ -z "$app" ]] && continue
    [[ "$app" =~ ^# ]] && continue

    if flatpak info "$app" >/dev/null 2>&1
    then
        log "${YELLOW}✓ $app already installed${NC}"
    else
        log "${BLUE}Installing $app${NC}"

        flatpak install -y flathub "$app" \
            || log "${RED}Failed: $app${NC}"
    fi

done < flatpak-packages.txt

#########################################
# OpenBangla
#########################################

if ! rpm -q openbangla-keyboard >/dev/null
then
    sudo dnf copr enable -y sayan/OpenBangla-Keyboard
    sudo dnf install -y openbangla-keyboard
fi

#########################################
# Brave
#########################################

mkdir -p ~/.config

cp brave-flags.conf ~/.config/

#########################################
# GNOME
#########################################

bash gnome-settings.sh

#########################################
# Finish
#########################################

log ""
log "${GREEN}=================================="
log "Setup Complete"
log "==================================${NC}"

log ""
log "Next Steps:"
log " • Brave Sync"
log " • Bitwarden Login"
log " • Fingerprint (fprintd-enroll)"
log " • Dash to Dock"
log " • Wallpaper"

log ""
log "See install.log for details."