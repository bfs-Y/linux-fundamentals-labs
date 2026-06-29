#!/bin/bash
# Detect and fix poisoned ARP cache

GATEWAY="192.168.122.1"
LEGITIMATE_MAC="52:54:00:89:4f:85"
IFACE="enp1s0"

echo "[CHECK] Current ARP entry for gateway:"
ip neigh show | grep $GATEWAY

CURRENT_MAC=$(ip neigh show | grep $GATEWAY | awk '{print $5}')

if [ "$CURRENT_MAC" != "$LEGITIMATE_MAC" ]; then
    echo "[ALERT] ARP POISONING DETECTED"
    echo "  Expected: $LEGITIMATE_MAC"
    echo "  Found:    $CURRENT_MAC"
    echo "[FIX] Flushing ARP cache..."
    sudo ip neigh flush all
    echo "[FIX] Restoring legitimate entry..."
    sudo ip neigh add $GATEWAY dev $IFACE lladdr $LEGITIMATE_MAC
    echo "[FIX] Verified:"
    ip neigh show | grep $GATEWAY
else
    echo "[OK] Gateway MAC matches legitimate entry: $LEGITIMATE_MAC"
fi
