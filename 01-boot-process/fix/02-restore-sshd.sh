#!/bin/bash
# 01-boot-process/fix/02-restore-sshd.sh
#
# FIX for break/02-missing-sshd.sh
# Root cause: openssh-server was never installed / was removed - not a
# boot failure, not a hung VM, not caused by any GRUB or reboot activity.
# Must be run from the VM's console (virt-viewer/virsh console), since
# SSH itself is the thing that's broken.

set -uo pipefail

echo "[fix] Installing openssh-server..."
sudo apt update
sudo apt install openssh-server -y

echo "[fix] Checking ssh.socket (Ubuntu uses socket activation by default -"
echo "[fix] ssh.service staying inactive/dead until a connection arrives is"
echo "[fix] expected, NOT a fault):"
systemctl status ssh.socket --no-pager

echo "[fix] From the HOST, verify: ssh ubuntulab@<this VM's IP>"
echo "[fix] Should now connect successfully."
