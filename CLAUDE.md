# Repository Guidance

## Purpose

This repository installs a CachyOS/Arch development environment using
Hyprland 0.55+ and Noctalia v5. Hyprland configuration is Lua and Noctalia
configuration is TOML. Do not reintroduce v4 Quickshell packages, JSON
settings, QML plugins, Matugen-generated Hyprland fragments, or `qs` IPC.

## Installer Flow

`install.sh` must be run as a regular sudo-enabled user:

```text
00-prereq.sh   -> full system upgrade and build prerequisites
10-pacman.sh   -> official packages and fonts
20-paru.sh     -> validate paru and build it from source when missing/broken
30-aur.sh      -> AUR packages, including noctalia-git
50-ohmyzsh.sh  -> shell setup
60-tools.sh    -> Atuin, Go tools, Noctalia binary check
65-nvim.sh     -> external Neovim configuration
70-dotfiles.sh -> symlink dotfiles
45-powerfix.sh -> optional Intel RAPL power cap
38-network.sh  -> NetworkManager+iwd configuration
40-services.sh -> Bluetooth, UPower, power profiles, Docker
```

All scripts use `set -euo pipefail` and should remain idempotent.

## Configuration Sources

- Hyprland: `dotfiles/config/hypr/hyprland.lua`
- Noctalia: `dotfiles/config/noctalia/config.toml`
- NetworkManager iwd backend: `config/system/20-wifi-backend.conf`
- Hyprland helpers: `dotfiles/config/hypr/scripts/`
- Pacman packages: `config/pacman.txt`
- AUR packages: `config/paru.txt`

The dotfile installer links top-level entries from `dotfiles/config/` into
`~/.config/`. Existing real files and directories are backed up before linking.

Noctalia GUI overrides are runtime state under
`~/.local/state/noctalia/settings.toml`; do not add that state file to the
repository.

## Hyprland Conventions

- Use the current `hl.*` Lua APIs.
- Use `hl.on("hyprland.start", ...)` for autostart.
- Use `hl.bind()` and typed dispatchers instead of legacy bind strings.
- Use `hl.window_rule()` and `hl.layer_rule()`.
- Keep the Noctalia namespace rule synchronized with upstream v5.
- Validate changes with:

```bash
Hyprland --verify-config --config dotfiles/config/hypr/hyprland.lua
```

## Noctalia Conventions

- Use `noctalia msg <command>` for IPC.
- Keep declarative settings in TOML.
- Prefer built-in v5 widgets over plugins.
- Only add v5 plugins that use the current Luau plugin API.
- Keep configuration small enough for upstream defaults to evolve.
- Validate with:

```bash
noctalia config validate dotfiles/config/noctalia/config.toml
```

## Networking

Noctalia's native network UI requires NetworkManager. This setup retains iwd
as NetworkManager's backend. Standalone `iwd.service` must not be enabled,
because it would race NetworkManager for the Wi-Fi device.

## Fresh-System Requirements

- working Pacman mirrors and internet
- regular user with sudo access
- valid system time
- installer is not run as root

No preinstalled AUR helper is required.
