#!/bin/bash
# 04-permission-directories/fix/02-restore-reader-access.sh
#
# Fix for break/02-acl-mask-blocks-reader.sh. The labreader entry in the
# ACL was never removed. chmod 600 set the mask to ---, and the mask caps
# every named entry, so the entry stopped working.
# Setting the mask back brings the access back. chmod 640 would also work,
# but I set the mask directly so it's clear what I'm changing.
# It only deletes the labreader account if the break script created it,
# and it only says "removed" after checking the account is really gone.
# On Rocky, sudo -u starts a short-lived systemd --user process for the
# account, and userdel refuses while it runs, so I end it and wait first.

set -u

DIR=/tmp/aclcase
CONF=$DIR/app.conf

[ -f "$CONF" ] || { echo "$CONF not found. Run break/02 first."; exit 1; }
id labreader >/dev/null 2>&1 || { echo "labreader doesn't exist."; exit 1; }

echo "Before. ls -l says:"
ls -l "$CONF"
echo "getfacl says:"
getfacl "$CONF" 2>/dev/null | grep -E 'labreader|mask'

setfacl -m m::r-- "$CONF"

echo
echo "After setting the mask. ls -l says:"
ls -l "$CONF"
echo "getfacl says:"
getfacl "$CONF" 2>/dev/null | grep -E 'labreader|mask'

if sudo -u labreader cat "$CONF" >/dev/null 2>&1; then
    RESULT="labreader can read the file again"
else
    RESULT="labreader is still blocked"
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
