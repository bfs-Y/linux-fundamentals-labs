#!/bin/bash
# 04-permission-directories/fix/03-restore-directory-execute.sh
#
# Fix for break/03-directory-execute-removed.sh. The folder had r but no
# x for other users, so they could read the list of names and nothing
# else. Adding x back lets them reach the files inside.
# It only deletes the labreader account if the break script created it,
# and it only says "removed" after checking the account is really gone.
# On Rocky, sudo -u starts a short-lived systemd --user process for the
# account, and userdel refuses while it runs, so I end it and wait first.

set -u

DIR=/tmp/dirlab

[ -f "$DIR/d/file.txt" ] || { echo "$DIR/d/file.txt not found. Run break/03 first."; exit 1; }
id labreader >/dev/null 2>&1 || { echo "labreader doesn't exist."; exit 1; }

echo "Before. The folder is:"
ls -ld "$DIR/d"

chmod 755 "$DIR/d"

echo "After chmod 755. The folder is:"
ls -ld "$DIR/d"
echo "labreader runs ls -l:"
sudo -u labreader ls -l "$DIR/d" 2>&1

if sudo -u labreader cat "$DIR/d/file.txt" >/dev/null 2>&1; then
    RESULT="labreader can open the file again"
else
    RESULT="labreader still cannot open the file"
fi

NOTE="left labreader in place"
KEEP=no
if [ -f "$DIR/.created-labreader" ]; then
    sudo loginctl terminate-user labreader || true
    for i in 1 2 3 4 5 6 7 8 9 10; do
        pgrep -u labreader >/dev/null || break
        sleep 1
    done
    if sudo userdel -r labreader; then
        if id labreader >/dev/null 2>&1; then
            NOTE="userdel said it worked but labreader still exists"
            KEEP=yes
        else
            NOTE="removed labreader"
        fi
    else
        NOTE="userdel failed (message above), labreader is still there"
        KEEP=yes
    fi
fi

if [ "$KEEP" = yes ]; then
    LAB="lab folder kept"
else
    cd / && rm -rf "$DIR"
    LAB="lab removed"
fi
echo "RESULT: $RESULT, $NOTE, $LAB"
