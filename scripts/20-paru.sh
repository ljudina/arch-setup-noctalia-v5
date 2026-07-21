#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib.sh"

if command -v paru >/dev/null 2>&1 && paru --version >/dev/null 2>&1; then
  log "paru already installed"
  return 0
fi

if command -v paru >/dev/null 2>&1; then
  warn "Existing paru cannot load against the current libalpm; rebuilding it"
fi

# paru-bin can be linked against an older libalpm soname after a Pacman ABI
# upgrade. Remove it before installing the locally compiled `paru` package,
# which links against the libalpm version present on this machine.
if pacman -Qq paru-bin >/dev/null 2>&1; then
  log "Removing incompatible paru-bin package"
  sudo pacman -R --noconfirm paru-bin
fi

log "Building paru from source against the installed Pacman/libalpm"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

git clone --depth=1 https://aur.archlinux.org/paru.git "$tmpdir/paru"
(
  cd "$tmpdir/paru"
  makepkg --syncdeps --install --noconfirm
)

need_cmd paru
paru --version >/dev/null 2>&1 || {
  err "paru was installed but cannot load against the current libalpm"
  exit 1
}
