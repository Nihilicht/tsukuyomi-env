#!/usr/bin/env bash

# 1. Get Boot Time from /proc/uptime (Total seconds since boot)
UPTIME_SECONDS=$(awk '{print int($1)}' /proc/uptime)
CURRENT_UNIX=$(date +%s)
BOOT_TIME=$((CURRENT_UNIX - UPTIME_SECONDS))

# 2. Get OS Installation Time (using root partition birth/creation time)
# Fallback to modification time if Birth is not available.
OS_INSTALL_RAW=$(stat -c %W / 2>/dev/null)
if [[ "$OS_INSTALL_RAW" == "0" || -z "$OS_INSTALL_RAW" ]]; then
    OS_INSTALL_RAW=$(stat -c %Y /)
fi

jq -n \
  --argjson boot_ts "$BOOT_TIME" \
  --argjson os_install_ts "$OS_INSTALL_RAW" \
  '{
    boot: $boot_ts,
    osInstall: $os_install_ts
  }'

