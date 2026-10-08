# Linux Workstation Setup (Fedora & Debian)

Personal Workstation Setup supporting both **Fedora** and **Debian** (including Debian-based distributions like Ubuntu/Mint).

## Usage

Make scripts executable:

```bash
chmod +x install.sh gnome-settings.sh post-install.sh update.sh cleanup.sh
```

Run installation (auto-detects distribution, or specify explicitly):

```bash
# Auto-detects OS from /etc/os-release
./install.sh

# Or specify target distribution explicitly:
./install.sh fedora
./install.sh debian
```

After installation:

```bash
./post-install.sh
```

Maintenance & Cleanup:

```bash
./update.sh   # Upgrade DNF/APT and Flatpak packages
./cleanup.sh  # Remove unused packages and clean package cache
```

## Structure

- `install.sh` - Main installation script (supports Fedora & Debian)
- `update.sh` - System (DNF/APT) and Flatpak update script
- `cleanup.sh` - Package cache cleanup and unused packages autoremove
- `dnf-packages.txt` - Core CLI & GUI packages for Fedora via DNF
- `apt-packages.txt` - Core CLI & GUI packages for Debian via APT
- `flatpak-packages.txt` - Sandboxed GUI desktop apps (Flathub)
- `gnome-settings.sh` - GNOME interface preferences & keybindings
- `post-install.sh` - Hardware overview & post-install checklist
- `brave-flags.conf` - Browser launch configuration flags
- `configs/` - App configuration dotfiles
- `fonts/` - Bengali & system fonts (automatically installed to `~/.local/share/fonts`)
- `wallpapers/` - Custom desktop backgrounds
- `scripts/` - Custom utility scripts

## Features & Configuration

- **Package Management**: Installs development tools, media utilities, and system monitors via native package manager (DNF on Fedora, APT on Debian) and Flatpak.
- **Repositories**: Enables RPM Fusion (Free & Nonfree) on Fedora; enables `contrib` and `non-free` components on Debian.
- **Input Method**: Installs OpenBangla Keyboard (`ibus-openbangla`) tailored for each distribution.
- **Typography**: Restores Bengali fonts to `~/.local/share/fonts` and updates font cache.
- **Desktop Preferences**: Configures GNOME dark mode, tap-to-click, and window button layout.
- **Browser**: Deploys `brave-flags.conf` to `~/.config/`.
