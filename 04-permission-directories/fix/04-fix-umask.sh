#!/bin/bash
# 04-permission-directories/fix/04-fix-umask.sh
#
# Fix for break/04-umask-hides-new-files.sh. The file was created under
# umask 077, so the group got no access. Two changes: chmod 640 fixes the
# file that already exists, and umask 027 in the writing script fixes the
# files it makes from now on. 027 gives the group read access and keeps
# everyone else out, which 022 would not.
# It only deletes the labreader account if the break script created it,
# and it only says "removed" after checking the account is really gone.
# On Rocky, sudo -u starts a short-lived systemd --user process for the
# account, and userdel refuses while it runs, so I end it and wait first.

set -u

DIR=/tmp/umasklab
F=$DIR/app.conf

[ -f "$F" ] || { echo "$F not found. Run break/04 first."; exit 1; }
id labreader >/dev/null 2>&1 || { echo "labreader doesn't exist."; exit 1; }

echo "Before:"
ls -l "$F"

chmod 640 "$F"
echo "After chmod 640 on the existing file:"
ls -l "$F"

echo "A new file made under umask 027:"
( umask 027; echo "new=value" > "$DIR/new.conf" )
sudo chgrp labreader "$DIR/new.conf"
ls -l "$DIR/new.conf"

if sudo -u labreader cat "$F" >/dev/null 2>&1 && sudo -u labreader cat "$DIR/new.conf" >/dev/null 2>&1; then
    RESULT="labreader reads both the old file and the new one"
else
    RESULT="labreader is still blocked on at least one file"
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
