#!/bin/bash
# firstrun.sh — injected by rover SD card Wi-Fi reconfiguration (2026-05-25)
# Adds Sunrise_6992877 NetworkManager connection on first Pi boot.
# IMPORTANT: Replace WIFI_PASSWORD_PLACEHOLDER below with the actual Wi-Fi password
# before booting the Raspberry Pi!

set -e

SSID="Sunrise_6992877"
PSK="WIFI_PASSWORD_PLACEHOLDER"
CONN_UUID="d9b03ec7-b965-4003-8564-aa5d62f2f9b7"
NM_DIR="/etc/NetworkManager/system-connections"
CONN_FILE="${NM_DIR}/${SSID}.nmconnection"

# Write the NetworkManager connection profile
mkdir -p "$NM_DIR"
cat > "$CONN_FILE" << CONN_EOF
[connection]
id=${SSID}
uuid=${CONN_UUID}
type=wifi
autoconnect=true
autoconnect-priority=20

[wifi]
mode=infrastructure
ssid=${SSID}

[wifi-security]
auth-alg=open
key-mgmt=wpa-psk
psk=${PSK}

[ipv4]
method=auto

[ipv6]
addr-gen-mode=default
method=auto
CONN_EOF

chmod 600 "$CONN_FILE"

# Reload NetworkManager to pick up the new connection (if it is already running)
if systemctl is-active --quiet NetworkManager 2>/dev/null; then
    nmcli connection reload || true
fi

# Remove firstrun from cmdline.txt to prevent re-running on subsequent boots
if mountpoint -q /boot/firmware 2>/dev/null; then
    BOOT=/boot/firmware
elif [ -d /boot ]; then
    BOOT=/boot
fi
if [ -f "${BOOT}/cmdline.txt" ]; then
    sed -i 's/ systemd\.run=\/boot\/firmware\/firstrun\.sh//g' "${BOOT}/cmdline.txt"
    sed -i 's/ systemd\.run_success_action=none//g' "${BOOT}/cmdline.txt"
fi
