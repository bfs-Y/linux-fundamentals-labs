#!/bin/bash
# Hardens /tmp against binary execution attacks
# Prevents attackers from planting and running executables in /tmp
# Requires root.

set -euo pipefail

echo "=== Current /tmp mount options ==="
mount | grep /tmp || echo "/tmp has no special mount options — vulnerable"

echo ""
echo "=== Checking /etc/fstab for /tmp entry ==="
grep /tmp /etc/fstab || echo "No /tmp entry in fstab — using defaults"

echo ""
echo "=== Applying noexec to /tmp ==="
if grep -q "^tmpfs /tmp" /etc/fstab; then
    echo "Entry exists — update manually to add noexec,nosuid,nodev"
    grep /tmp /etc/fstab
else
    echo "Adding /tmp entry to /etc/fstab"
    echo "tmpfs /tmp tmpfs defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
    echo "Added. Remount to activate:"
    echo "  sudo mount -o remount /tmp"
fi

echo ""
echo "=== Verify after remount ==="
echo "Run: mount | grep /tmp"
echo "Should show: noexec,nosuid,nodev"

echo ""
echo "=== Test noexec is working ==="
echo "cp /bin/sleep /tmp/test-exec"
echo "chmod +x /tmp/test-exec"
echo "/tmp/test-exec 1 — should fail with Permission denied"
