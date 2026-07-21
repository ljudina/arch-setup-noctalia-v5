#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib.sh"

need_cmd nmcli

log "Configuring NetworkManager to use iwd for Wi-Fi"
sudo install -d -m 755 /etc/NetworkManager/conf.d
sudo install -m 644 \
  "$ROOT_DIR/config/system/20-wifi-backend.conf" \
  /etc/NetworkManager/conf.d/20-wifi-backend.conf

# NetworkManager starts and owns the iwd daemon when this backend is selected.
# A separately enabled iwd.service would race NetworkManager for the device.
if systemctl is-enabled --quiet iwd.service 2>/dev/null || \
   systemctl is-active --quiet iwd.service 2>/dev/null; then
  log "Disabling standalone iwd.service"
  sudo systemctl disable --now iwd.service
fi

enable_service_now NetworkManager.service
