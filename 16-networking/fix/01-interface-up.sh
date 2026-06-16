#!/bin/bash
# Fix 01: Bring network interface back up
# Pairs with: break/01-interface-down.sh

IFACE="enp1s0"

echo "[FIX] Bringing $IFACE up..."
sudo ip link set "$IFACE" up
sleep 3
echo "[VERIFY] Current state:"
ip a show "$IFACE"
