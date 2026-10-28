#!/bin/bash
# 05-users-sudo/fix/01-restore-group-memberships.sh
#
# Fix for break/01. Restores the ORIGINAL groups (audio, video) and removes
# sudo, which drilluser never had. -aG appends, -G replaces. Then it
# removes drilluser and the lab folder.

set -u
U=drilluser
DIR=/tmp/usermodlab
F=$DIR/video.conf

[ -f "$F" ] || { echo "$F not found. Run break/01 first."; exit 1; }
id "$U" >/dev/null 2>&1 || { echo "$U doesn't exist."; exit 1; }

echo "Before: $(id "$U")"
sudo gpasswd -d "$U" sudo >/dev/null
sudo usermod -aG audio,video "$U"
echo "After: $(id "$U")"

if sudo -u "$U" cat "$F" >/dev/null 2>&1; then
    RESULT="$U reads the file again, sudo removed"
else
    RESULT="$U is still denied"
fi

sudo loginctl terminate-user "$U" 2>/dev/null || true
for i in 1 2 3 4 5 6 7 8 9 10; do pgrep -u "$U" >/dev/null || break; sleep 1; done
if sudo userdel -r "$U" 2>/dev/null && ! id "$U" >/dev/null 2>&1; then
    cd / && rm -rf "$DIR"
    echo "RESULT: $RESULT, removed $U, lab removed"
else
    echo "RESULT: $RESULT, userdel did not finish, $U and $DIR kept"
fi
