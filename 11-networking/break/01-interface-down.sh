#!/bin/bash
# Break 01: Take network interface down
# Effect: interface loses IP, all traffic stops
# Recovery: fix/01-interface-up.sh

IFACE="enp1s0"

echo "[BREAK] Taking $IFACE down..."
sudo ip link set "$IFACE" down
echo "[VERIFY] Current state:"
ip a show "$IFACE"
