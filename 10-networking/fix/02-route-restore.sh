#!/bin/bash
# Fix 02: Restore default gateway
# Pairs with: break/02-route-delete.sh

GW="192.168.122.1"
IFACE="enp1s0"

echo "[FIX] Restoring default gateway..."
sudo ip route add default via "$GW" dev "$IFACE"
echo "[VERIFY] Route table:"
ip route show
echo "[TEST] Ping internet:"
ping -c 2 8.8.8.8
