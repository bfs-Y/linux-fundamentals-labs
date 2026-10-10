#!/bin/bash
# 02-logs-auditing/break/01-loop-filesystem-full.sh
#
# Fills a small loop filesystem so I can see what a full log disk looks
# like. Needs sudo. The real /var/log is never touched.
# It leaves the filesystem mounted and full on purpose.
# Undo it with fix/01-reclaim-space.sh.

set -u

IMG=/tmp/logtest.img
MNT=/mnt/logtest

if mountpoint -q "$MNT"; then
    echo "$MNT is already mounted. Run the fix script first."
    exit 1
fi

sudo fallocate -l 50M "$IMG"
sudo mkfs.ext4 -q "$IMG"
sudo mkdir -p "$MNT"
sudo mount -o loop "$IMG" "$MNT"
echo "Fresh filesystem:"
df -h "$MNT"

echo
echo "Filling it as root. dd is supposed to fail at the end."
sudo dd if=/dev/zero of="$MNT/filler.bin" bs=1M count=100 2>&1 | tail -3
echo
echo "After the fill:"
df -h "$MNT"
stat -f -c 'free=%f available=%a' "$MNT"

echo
echo "Appending a log line as root:"
sudo bash -c "echo 'test log entry' >> $MNT/app.log"
echo "exit status: $?"
