#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib.sh"

need_cmd sudo

log "Validating sudo access"
sudo -v

log "Fully upgrading the CachyOS/Arch system"
sudo pacman -Syu --needed --noconfirm

log "Installing build and download prerequisites"
sudo pacman -S --needed --noconfirm git base-devel curl ca-certificates

need_cmd git
need_cmd curl
need_cmd makepkg
