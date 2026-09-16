#!/bin/bash
# Break 02: Delete default gateway
# Effect: local network works, internet goes dark
# Recovery: fix/02-route-restore.sh

echo "[BREAK] Deleting default gateway..."
sudo ip route del default
echo "[VERIFY] Route table:"
ip route show
echo "[TEST] Ping internet:"
ping -c 2 8.8.8.8
