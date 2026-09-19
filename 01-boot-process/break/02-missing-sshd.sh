#!/bin/bash
# 01-boot-process/break/02-missing-sshd.sh
#
# BREAK: remove openssh-server entirely, reproducing a real incident:
# SSH refused on a fully healthy, fully booted VM. The point of this
# drill is diagnosing "Connection refused" correctly - distinguishing
# it from a boot failure, a hung VM, or a network problem - using only
# host-side (virsh) tools plus direct console access, without assuming
# the most recent change (a reboot, a config edit) is the cause.
#
# BLAST RADIUS: removes SSH access to this VM. Recovery requires the
# hypervisor's graphical console (virt-viewer) or serial console access -
# NOT SSH, since that's the exact thing being removed. Confirm you have
# an alternate way into the VM before running this.

set -uo pipefail

echo "[break] Confirming ssh.socket is currently active..."
systemctl status ssh.socket --no-pager || true

echo "[break] Removing openssh-server..."
sudo apt remove --purge openssh-server -y

echo "[break] Confirming removal..."
dpkg -l | grep openssh-server || echo "[break] Confirmed: openssh-server no longer installed."

echo "[break] From the HOST, attempt: ssh ubuntulab@<this VM's IP>"
echo "[break] Expected: Connection refused (port reachable, nothing listening -"
echo "[break] NOT a timeout, NOT no-route-to-host). Diagnose from there."
