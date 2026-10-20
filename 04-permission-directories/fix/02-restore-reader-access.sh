#!/bin/bash
# 04-permission-directories/fix/02-restore-reader-access.sh
#
# Fix for break/02-acl-mask-blocks-reader.sh. The labreader entry in the
# ACL was never removed. chmod 600 set the mask to ---, and the mask caps
# every named entry, so the entry stopped working.
# Setting the mask back brings the access back. chmod 640 would also work,
# but I set the mask directly so it's clear what I'm changing.
# Removes /tmp/aclcase at the end. It only deletes the labreader account
# if the break script created it.

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

if [ -f "$DIR/.created-labreader" ]; then
    sudo userdel -r labreader 2>/dev/null
    NOTE="removed labreader"
else
    NOTE="left labreader in place"
fi

cd / && rm -rf "$DIR"
echo "RESULT: $RESULT, $NOTE, lab removed"
