#!/bin/bash
# 01-boot-process/break/01-grub-verbosity-change.sh
#
# BREAK: remove "quiet splash" from the kernel command line so the next
# boot shows full verbose kernel/systemd output instead of hiding it
# behind the graphical splash screen.
#
# Safe, reversible: keeps a .bak of /etc/default/grub before editing, and
# does not touch root filesystem, kernel version, or initramfs selection.
#
# BLAST RADIUS: requires a reboot to observe the effect. Low risk - only
# changes boot verbosity, not what boots or how root is mounted.

set -uo pipefail

GRUB_FILE="/etc/default/grub"

echo "[break] Current GRUB_CMDLINE_LINUX_DEFAULT:"
grep '^GRUB_CMDLINE_LINUX_DEFAULT=' "$GRUB_FILE"

echo "[break] Backing up and editing $GRUB_FILE..."
sudo sed -i.bak 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/GRUB_CMDLINE_LINUX_DEFAULT=""/' "$GRUB_FILE"

echo "[break] New value:"
grep '^GRUB_CMDLINE_LINUX_DEFAULT=' "$GRUB_FILE"

echo "[break] Regenerating grub.cfg..."
sudo update-grub

echo "[break] Verifying quiet/splash absent from generated config:"
sudo grep 'quiet splash' /boot/grub/grub.cfg || echo "[break] Confirmed: not present."

echo "[break] Reboot manually to observe verbose boot output:"
echo "[break]   sudo reboot"
