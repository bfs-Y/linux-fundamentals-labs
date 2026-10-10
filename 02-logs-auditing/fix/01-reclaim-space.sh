#!/bin/bash
# Fix for break/01. Deletes the filler file, checks that a root write
# works again, then removes the loop filesystem.
# If umount says "busy", cd out of /mnt/logtest in your own shell first.

set -u
IMG=/tmp/logtest.img
MNT=/mnt/logtest

if ! mountpoint -q "$MNT"; then
    echo "$MNT is not mounted. Run break/01 first."
    exit 1
fi

echo "Before:"; df -h "$MNT" | tail -1
sudo rm -f "$MNT/filler.bin"
echo "After deleting the filler:"; df -h "$MNT" | tail -1

WRITE=failed
if sudo bash -c "echo 'log line after cleanup' >> $MNT/app.log"; then
    WRITE=worked
fi

cd / && sudo umount "$MNT" && sudo rmdir "$MNT" && sudo rm -f "$IMG"
if mountpoint -q "$MNT"; then
    echo "RESULT: write $WRITE, but $MNT is still mounted"
else
    echo "RESULT: write $WRITE, lab removed"
fi
