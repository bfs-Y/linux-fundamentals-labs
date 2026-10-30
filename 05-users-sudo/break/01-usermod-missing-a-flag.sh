#!/bin/bash
# 05-users-sudo/break/01-usermod-missing-a-flag.sh
# Run ONE break/fix pair at a time.
#
# usermod -G (no -a) REPLACES all supplementary groups. drilluser starts in
# audio and video, a file is readable only through video, then the
# "add admin rights" command drops both groups and the file stops working.
# The admin group is sudo on Ubuntu and wheel on Rocky, so the script
# picks whichever exists.
# Needs sudo. Leaves the broken state until fix/01 runs.

set -u
U=drilluser
DIR=/tmp/usermodlab
F=$DIR/video.conf

ADMIN=sudo
getent group sudo >/dev/null || ADMIN=wheel
for g in audio video "$ADMIN"; do
    getent group "$g" >/dev/null || { echo "group $g does not exist here. Stopping."; exit 1; }
done

[ -e "$DIR" ] && { echo "$DIR exists. Run the fix script first."; exit 1; }
id "$U" >/dev/null 2>&1 && { echo "$U already exists. Not touching it."; exit 1; }

sudo useradd -m -s /bin/bash "$U"
mkdir "$DIR"
echo "setting=value" | sudo tee "$F" >/dev/null
sudo chgrp video "$F"
sudo chmod 640 "$F"
sudo usermod -aG audio,video "$U"

echo "Before: $(id "$U")"
echo "Reads: $(sudo -u "$U" cat "$F" 2>&1)"

echo "Change: usermod -G $ADMIN $U (no -a)"
sudo usermod -G "$ADMIN" "$U"
echo "After: $(id "$U")"
echo "Reads: $(sudo -u "$U" cat "$F" 2>&1)"

if sudo -u "$U" cat "$F" >/dev/null 2>&1; then
    echo "RESULT: still readable"
else
    echo "RESULT: audio and video are gone, so the file is denied (and $ADMIN was added by mistake)"
fi
