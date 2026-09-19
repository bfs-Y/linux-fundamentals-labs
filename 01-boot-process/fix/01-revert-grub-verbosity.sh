#!/bin/bash
# 01-boot-process/fix/01-revert-grub-verbosity.sh
#
# FIX for break/01-grub-verbosity-change.sh
# Restores GRUB_CMDLINE_LINUX_DEFAULT from the .bak created by the break
# script, regenerates grub.cfg, and verifies the restoration reached the
# actual file GRUB reads at boot - not just the source config.

set -uo pipefail

GRUB_FILE="/etc/default/grub"
GRUB_BACKUP="/etc/default/grub.bak"

if [ ! -f "$GRUB_BACKUP" ]; then
    echo "[fix] ERROR: $GRUB_BACKUP not found. Cannot auto-revert."
    echo "[fix] Manually edit $GRUB_FILE to restore GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\""
    exit 1
fi

echo "[fix] Restoring $GRUB_FILE from backup..."
sudo cp "$GRUB_BACKUP" "$GRUB_FILE"

echo "[fix] Confirming restored value:"
grep '^GRUB_CMDLINE_LINUX_DEFAULT=' "$GRUB_FILE"

echo "[fix] Regenerating grub.cfg..."
sudo update-grub

echo "[fix] Verifying quiet splash present in generated config:"
sudo grep 'quiet splash' /boot/grub/grub.cfg

echo "[fix] Reboot manually to confirm on next boot:"
echo "[fix]   sudo reboot"
