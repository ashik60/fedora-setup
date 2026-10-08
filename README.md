# Fedora Setup

Personal Fedora Workstation Setup

## Usage

```bash
chmod +x install.sh
chmod +x gnome-settings.sh
chmod +x post-install.sh

./install.sh
```

After installation:

```bash
./post-install.sh
```

Maintenance & Cleanup:

```bash
./update.sh   # Upgrade DNF and Flatpak packages
./cleanup.sh  # Remove unused packages and clean package cache
```

## Structure

- `install.sh` - Main installation script
- `update.sh` - System and Flatpak update script
- `cleanup.sh` - Package cache cleanup and unused packages autoremove
- `dnf-packages.txt` - Core CLI & GUI packages via DNF
- `flatpak-packages.txt` - Sandboxed GUI desktop apps
- `gnome-settings.sh` - GNOME interface preferences & keybindings
- `post-install.sh` - Hardware overview & post-install checklist
- `brave-flags.conf` - Browser launch configuration flags
- `configs/` - App configuration dotfiles
- `fonts/` - Bengali & system fonts
- `wallpapers/` - Custom desktop backgrounds
- `scripts/` - Custom utility scripts

## Setup Status

- **Operating System**: Fedora Linux 44 (Workstation Edition)
- **Linux Kernel**: 7.2.5
- **Repositories**: RPM Fusion (Free & Nonfree) enabled, OpenBangla COPR enabled
- **Desktop Environment**: GNOME with dark theme, tap-to-click, and Dash to Dock active
- **Hardware Integration**: Fingerprint authentication configured (`fprintd`)
- **Input Method**: OpenBangla Keyboard (`ibus-openbangla`) configured and active
- **Typography**: Bengali fonts installed in `~/.local/share/fonts`
- **Browser**: Brave Browser installed with flags deployed in `~/.config/brave-flags.conf`
- **Package Status**:
  - DNF packages: 28 / 41 installed
  - Flatpaks: 4 / 6 applications installed

