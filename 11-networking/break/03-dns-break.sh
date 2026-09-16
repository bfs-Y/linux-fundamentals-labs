#!/bin/bash
# Break 03: Point DNS at unreachable/invalid server
# Effect: name resolution fails, IP-based connectivity unaffected
# Recovery: fix/03-dns-restore.sh

IFACE="enp1s0"

echo "[BREAK] Setting invalid DNS server on $IFACE..."
sudo resolvectl revert "$IFACE"
echo "[VERIFY] DNS status:"
resolvectl status "$IFACE"
echo "[TEST] Name resolution (should fail):"
ping -c 2 google.com
echo "[CONTROL] Raw IP still works:"
ping -c 2 8.8.8.8
