#!/bin/bash
# Fix 03: Restore DNS resolution
# Pairs with: break/03-dns-break.sh
# Note: resolvectl revert alone may not restore DHCP-provided DNS.
# Restarting systemd-resolved forces a fresh DHCP DNS pickup.

echo "[FIX] Restarting systemd-resolved..."
sudo systemctl restart systemd-resolved
echo "[VERIFY] DNS status:"
resolvectl status
echo "[TEST] Name resolution:"
ping -c 2 google.com
