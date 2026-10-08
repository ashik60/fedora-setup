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

#########################################
# Distribution Detection & Selection
#########################################

DISTRO=""
TARGET="${1:-}"

# Read /etc/os-release if available
OS_ID=""
VERSION_ID=""
if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_ID="${ID:-}"
    VERSION_ID="${VERSION_ID:-}"
fi

case "${TARGET,,}" in
    fedora|--fedora)
        DISTRO="fedora"
        ;;
    debian|--debian)
        DISTRO="debian"
        ;;
    "")
        if [[ "$OS_ID" =~ (fedora|rhel|centos) ]]; then
            DISTRO="fedora"
        elif [[ "$OS_ID" =~ (debian|ubuntu|linuxmint|pop) ]]; then
            DISTRO="debian"
        else
            echo "Unable to auto-detect supported distribution."
            echo "Please choose target OS:"
            echo "  1) Fedora"
            echo "  2) Debian"
            read -rp "Enter choice [1/2]: " choice
            case "$choice" in
                1) DISTRO="fedora" ;;
                2) DISTRO="debian" ;;
                *) echo "Invalid choice. Aborting."; exit 1 ;;
            esac
        fi
        ;;
    *)
        echo "Unknown option '$TARGET'. Usage: ./install.sh [fedora|debian]"
        exit 1
        ;;
esac

log "${BLUE}"
log "======================================="
log " Workstation Setup (${DISTRO^})"
log "======================================="
log "${NC}"

#########################################
# System Update & Repositories
#########################################

if [ "$DISTRO" = "fedora" ]; then
    log "${GREEN}Updating Fedora...${NC}"
    sudo dnf upgrade -y

    if ! rpm -q rpmfusion-free-release >/dev/null 2>&1; then
        log "${GREEN}Installing RPM Fusion...${NC}"
        sudo dnf install -y \
            https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
            https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    else
        log "${YELLOW}RPM Fusion already installed.${NC}"
    fi

elif [ "$DISTRO" = "debian" ]; then
    log "${GREEN}Updating Debian package lists and system...${NC}"
    sudo apt-get update -y
    sudo apt-get upgrade -y

    # Enable contrib, non-free, and non-free-firmware if software-properties-common available
    if command -v add-apt-repository >/dev/null 2>&1; then
        sudo add-apt-repository -y contrib non-free non-free-firmware 2>/dev/null || true
    fi
fi

#########################################
# System Packages
#########################################

if [ "$DISTRO" = "fedora" ]; then
    log "${GREEN}Installing DNF packages...${NC}"

    while read -r package; do
        [[ -z "$package" ]] && continue
        [[ "$package" =~ ^# ]] && continue

        if rpm -q "$package" >/dev/null 2>&1; then
            log "${YELLOW}✓ $package already installed${NC}"
        else
            log "${BLUE}Installing $package${NC}"
            sudo dnf install -y "$package" || log "${RED}Failed: $package${NC}"
        fi
    done < dnf-packages.txt

elif [ "$DISTRO" = "debian" ]; then
    log "${GREEN}Installing APT packages...${NC}"

    while read -r package; do
        [[ -z "$package" ]] && continue
        [[ "$package" =~ ^# ]] && continue

        if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "ok installed"; then
            log "${YELLOW}✓ $package already installed${NC}"
        else
            log "${BLUE}Installing $package${NC}"
            sudo apt-get install -y "$package" || log "${RED}Failed: $package${NC}"
        fi
    done < apt-packages.txt

    # Debian bat and fd symlinks
    mkdir -p ~/.local/bin
    if [ -f /usr/bin/batcat ] && [ ! -e ~/.local/bin/bat ]; then
        ln -sf /usr/bin/batcat ~/.local/bin/bat
    fi
    if [ -f /usr/bin/fdfind ] && [ ! -e ~/.local/bin/fd ]; then
        ln -sf /usr/bin/fdfind ~/.local/bin/fd
    fi
fi

#########################################
# Flatpak
#########################################

if [ "$DISTRO" = "fedora" ]; then
    if ! rpm -q flatpak >/dev/null 2>&1; then
        sudo dnf install -y flatpak
    fi
elif [ "$DISTRO" = "debian" ]; then
    if ! dpkg-query -W -f='${Status}' flatpak 2>/dev/null | grep -q "ok installed"; then
        sudo apt-get install -y flatpak gnome-software-plugin-flatpak
    fi
fi

flatpak remote-add --if-not-exists flathub \
    https://flathub.org/repo/flathub.flatpakrepo

#########################################
# Flatpaks
#########################################

log "${GREEN}Installing Flatpaks...${NC}"

while read -r app; do
    [[ -z "$app" ]] && continue
    [[ "$app" =~ ^# ]] && continue

    if flatpak info "$app" >/dev/null 2>&1; then
        log "${YELLOW}✓ $app already installed${NC}"
    else
        log "${BLUE}Installing $app${NC}"
        flatpak install -y flathub "$app" || log "${RED}Failed: $app${NC}"
    fi
done < flatpak-packages.txt

#########################################
# OpenBangla
#########################################

if [ "$DISTRO" = "fedora" ]; then
    if ! rpm -q openbangla-keyboard >/dev/null 2>&1; then
        log "${GREEN}Installing OpenBangla Keyboard...${NC}"
        sudo dnf copr enable -y sayan/OpenBangla-Keyboard
        sudo dnf install -y openbangla-keyboard
    fi
elif [ "$DISTRO" = "debian" ]; then
    if ! dpkg-query -W -f='${Status}' openbangla-keyboard 2>/dev/null | grep -q "ok installed"; then
        log "${GREEN}Installing OpenBangla Keyboard...${NC}"
        DEB_MAJOR="${VERSION_ID%%.*}"
        [[ -z "$DEB_MAJOR" ]] && DEB_MAJOR="12"
        DEB_URL="https://github.com/OpenBangla/OpenBangla-Keyboard/releases/download/2.0.0/OpenBangla-Keyboard_2.0.0-debian${DEB_MAJOR}.deb"
        if ! curl --head --silent --fail "$DEB_URL" >/dev/null 2>&1; then
            DEB_URL="https://github.com/OpenBangla/OpenBangla-Keyboard/releases/download/2.0.0/OpenBangla-Keyboard_2.0.0-debian12.deb"
        fi
        curl -fsSL "$DEB_URL" -o /tmp/openbangla.deb && \
            sudo apt-get install -y /tmp/openbangla.deb && \
            rm -f /tmp/openbangla.deb || log "${RED}Failed: openbangla-keyboard${NC}"
    fi
fi

#########################################
# Fonts
#########################################

if [ -d "fonts" ] && compgen -G "fonts/*.ttf" >/dev/null; then
    log "${GREEN}Installing fonts...${NC}"
    mkdir -p ~/.local/share/fonts
    cp -n fonts/*.ttf ~/.local/share/fonts/ 2>/dev/null || true
    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f ~/.local/share/fonts 2>/dev/null || true
    fi
fi

#########################################
# Brave
#########################################

mkdir -p ~/.config
cp brave-flags.conf ~/.config/

#########################################
# GNOME
#########################################

if [ -f gnome-settings.sh ]; then
    bash gnome-settings.sh
fi

#########################################
# Finish
#########################################

log ""
log "${GREEN}=================================="
log "Setup Complete (${DISTRO^})"
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