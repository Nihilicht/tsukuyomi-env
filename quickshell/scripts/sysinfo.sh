#!/usr/bin/env bash

# 1. CPU Stats
CPU_RAW=$(grep -E '^cpu' /proc/stat)

# 2. Memory Info
MEM_INFO=$(cat /proc/meminfo)
MEM_TOTAL=$(echo "$MEM_INFO" | grep "MemTotal:" | awk '{print $2}')
MEM_AVAIL=$(echo "$MEM_INFO" | grep "MemAvailable:" | awk '{print $2}')
SWAP_TOTAL=$(echo "$MEM_INFO" | grep "SwapTotal:" | awk '{print $2}')
SWAP_FREE=$(echo "$MEM_INFO" | grep "SwapFree:" | awk '{print $2}')

# 3. GPU Usage and VRAM
GPU_DEV="/sys/class/drm/card1/device"
GPU_BUSY=$(cat "$GPU_DEV/gpu_busy_percent" 2>/dev/null || echo 0)
VRAM_USED=$(cat "$GPU_DEV/mem_info_vram_used" 2>/dev/null || echo 0)
VRAM_TOTAL=$(cat "$GPU_DEV/mem_info_vram_total" 2>/dev/null || echo 0)

# 4. Disk Usage
DISK_INFO=$(df -B1 / | tail -1)
DISK_SIZE=$(echo "$DISK_INFO" | awk '{print $2}')
DISK_USED=$(echo "$DISK_INFO" | awk '{print $3}')

# 5. Temperatures
TEMP_DATA=$(cat /sys/class/hwmon/hwmon*/temp*_input 2>/dev/null | tr '\n' ' ')

# 6. Network Stats
IFACE=$(ip route show default 2>/dev/null | awk '/default/ {print $5; exit}')

if [ -n "$IFACE" ]; then
    NET_RX=$(cat "/sys/class/net/$IFACE/statistics/rx_bytes" 2>/dev/null || echo 0)
    NET_TX=$(cat "/sys/class/net/$IFACE/statistics/tx_bytes" 2>/dev/null || echo 0)
    NET_IP=$(ip -4 addr show "$IFACE" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)
    NET_MAC=$(cat "/sys/class/net/$IFACE/address" 2>/dev/null | tr '[:lower:]' '[:upper:]')
    NET_GW="—"
    NET_DNS="—"
fi


[ -z "$NET_IP" ] && NET_IP="—"
[ -z "$NET_MAC" ] && NET_MAC="—"
[ -z "$NET_GW" ] && NET_GW="—"
[ -z "$NET_DNS" ] && NET_DNS="—"

# Construct JSON with jq
jq -n \
  --arg cpu "$CPU_RAW" \
  --argjson ram_total "${MEM_TOTAL:-0}" \
  --argjson ram_avail "${MEM_AVAIL:-0}" \
  --argjson swap_total "${SWAP_TOTAL:-0}" \
  --argjson swap_free "${SWAP_FREE:-0}" \
  --argjson gpu_busy "${GPU_BUSY:-0}" \
  --argjson vram_used "${VRAM_USED:-0}" \
  --argjson vram_total "${VRAM_TOTAL:-0}" \
  --argjson disk_total "${DISK_SIZE:-0}" \
  --argjson disk_used "${DISK_USED:-0}" \
  --arg temps "$TEMP_DATA" \
  --arg net_device "$IFACE" \
  --argjson net_rx "$NET_RX" \
  --argjson net_tx "$NET_TX" \
  --arg net_ip "$NET_IP" \
  --arg net_gateway "$NET_GW" \
  --arg net_dns "$NET_DNS" \
  --arg net_mac "$NET_MAC" \
  '{
    cpuRaw: $cpu | split("\n") | map(select(length > 0)),
    memory: {
      ram: { total: $ram_total, available: $ram_avail },
      swap: { total: $swap_total, free: $swap_free }
    },
    gpu: {
      busy: $gpu_busy,
      vram: { used: $vram_used, total: $vram_total }
    },
    disk: {
      total: $disk_total,
      used: $disk_used
    },
    temps: $temps | split(" ") | map(select(length > 0) | tonumber),
    network: {
      device: $net_device,
      rxBytes: $net_rx,
      txBytes: $net_tx,
      ip: $net_ip,
      gateway: $net_gateway,
      dns: $net_dns,
      mac: $net_mac
    }
  }'
