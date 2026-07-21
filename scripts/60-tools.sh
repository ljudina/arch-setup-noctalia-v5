#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib.sh"

install_atuin() {
  if command -v atuin >/dev/null 2>&1; then
    log "Atuin already installed"
    return 0
  fi
  log "Installing Atuin"
  curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
}

install_go_tools() {
  if ! command -v go >/dev/null 2>&1; then
    warn "Go not found, skipping Go tools"
    return 0
  fi

  log "Installing Go tools (templ, air)"
  go install github.com/a-h/templ/cmd/templ@latest
  go install github.com/air-verse/air@latest
}

check_noctalia() {
  if command -v noctalia >/dev/null 2>&1; then
    log "Noctalia v5 binary found"
  else
    warn "Noctalia binary not found after AUR installation"
  fi
}

set_gnome_dark() {
  if ! command -v gsettings >/dev/null 2>&1; then
    warn "gsettings not available, skipping GNOME dark mode"
    return 0
  fi
  log "Setting GNOME color-scheme prefer-dark (if schema exists)"
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
}

install_atuin
install_go_tools
check_noctalia
set_gnome_dark
