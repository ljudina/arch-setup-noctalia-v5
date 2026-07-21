# CachyOS Development Environment Setup (Noctalia v5)

A modular and idempotent CachyOS/Arch setup built around Hyprland 0.55+ and
Noctalia v5. Hyprland uses its current Lua configuration API and Noctalia uses
its native v5 runtime, TOML configuration, and `noctalia msg` IPC.

Noctalia v5 is currently distributed for Arch as the rolling
`noctalia-git` AUR package. This repository intentionally follows the current
v5 configuration rather than the incompatible Quickshell-based v4 line.

## Features

- Fresh CachyOS support with a full system upgrade
- Automatic source-built `paru` bootstrap when no AUR helper is installed
- Hyprland Lua configuration with persistent workspaces
- Noctalia v5 bar, launcher, lock screen, notifications, clipboard, wallpaper,
  weather, system monitoring, and control center
- NetworkManager with iwd as its Wi-Fi backend
- UPower, Bluetooth, and power-profiles-daemon integration
- Monitor hotplug and laptop lid reconciliation
- Foot terminal server/client setup
- Symlink-managed dotfiles with automatic backups
- Oh My Zsh, Powerlevel10k, Atuin, Yazi, and PHP-focused Neovim setup
- Optional Intel RAPL battery power cap

## Installation

Clone or copy this directory onto a fresh CachyOS installation, then run the
installer as your regular sudo-enabled user:

```bash
cd ~/src/arch-setup-noctalia-v5
./install.sh
```

Do not run `sudo ./install.sh`. The installer requests sudo only for system
operations.

The installer:

1. performs `pacman -Syu`
2. installs build and download prerequisites
3. installs official repository packages
4. builds `paru` from source against the installed Pacman/libalpm when needed
5. installs `noctalia-git` and the remaining AUR packages
6. installs shell, editor, and development tooling
7. deploys dotfiles through symlinks
8. configures NetworkManager to use iwd
9. enables required system services

A brief Wi-Fi interruption can occur near the end while standalone iwd is
replaced by NetworkManager managing the iwd backend.

After installation, reboot or log out and start a Hyprland session.

## Repository Structure

```text
.
├── install.sh
├── config/
│   ├── pacman.txt
│   ├── paru.txt
│   ├── fonts.txt
│   └── system/20-wifi-backend.conf
├── scripts/
│   ├── 00-prereq.sh
│   ├── 20-paru.sh
│   ├── 38-network.sh
│   ├── 40-services.sh
│   └── 70-dotfiles.sh
└── dotfiles/
    ├── config/
    │   ├── hypr/hyprland.lua
    │   ├── hypr/scripts/
    │   ├── noctalia/config.toml
    │   ├── foot/
    │   └── yazi/
    └── Pictures/wallpapers/
```

## Hyprland and Noctalia

Hyprland loads `~/.config/hypr/hyprland.lua`. The configuration preserves the
original workspace, monitor, input, application, group, and laptop behavior
while using the Lua API introduced as the preferred format in Hyprland 0.55.

Noctalia starts from the `hyprland.start` event. Keybindings use the v5 CLI:

```text
noctalia msg panel-toggle launcher
noctalia msg panel-toggle session
noctalia msg panel-toggle clipboard
noctalia msg settings-toggle
noctalia msg window-switcher
noctalia msg volume-up
```

The declarative configuration is
`~/.config/noctalia/config.toml`. Changes made through the GUI are stored
separately in `~/.local/state/noctalia/settings.toml` and override the tracked
configuration.

The old v4 JSON settings, Quickshell packages, Matugen fragments, cliphist
watchers, and QML plugins are intentionally not included. Their functionality
is replaced with v5 built-in widgets:

- network status and control
- keyboard layout
- weather
- network upload/download system monitors

Sticky notes are omitted because the old QML plugin is not compatible with the
v5 Luau plugin system.

## Networking

NetworkManager provides Noctalia's Wi-Fi and network controls. It uses iwd
through:

```ini
[device]
wifi.backend=iwd
```

The installer writes this to
`/etc/NetworkManager/conf.d/20-wifi-backend.conf`. Do not independently enable
`iwd.service`; NetworkManager starts and manages iwd.

## Validation and Troubleshooting

Validate Hyprland:

```bash
Hyprland --verify-config --config ~/.config/hypr/hyprland.lua
```

Validate Noctalia after installation:

```bash
noctalia config validate ~/.config/noctalia/config.toml
```

Inspect the effective Noctalia configuration:

```bash
noctalia config export full
```

Useful service checks:

```bash
systemctl status NetworkManager
systemctl status upower
systemctl status power-profiles-daemon
systemctl status bluetooth
```

The setup is safe to rerun. Existing real dotfiles are moved to
`<name>.bak.TIMESTAMP` before symlinks are created.

If a prebuilt `paru-bin` stops working after a Pacman/libalpm ABI upgrade,
rerunning the installer removes it and builds `paru` locally against the
current library version.

## License

MIT License
