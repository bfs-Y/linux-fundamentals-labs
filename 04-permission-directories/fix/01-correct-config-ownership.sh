#!/bin/bash
# 04-permission-directories/fix/01-correct-config-ownership.sh
#
# Fix for break/01-wrong-config-ownership.sh. The file stays owned by
# root, and the service account gets read access through the group
# (root:labreader, mode 640). The service can read its config and can't
# change it. I'd rather not give a service ownership of its own config.
# It only deletes the labreader account if the break script created it,
# and it only says "removed" after checking the account is really gone.
# On Rocky, sudo -u starts a short-lived systemd --user process for the
# account, and userdel refuses while it runs, so I end it and wait first.

set -u

CONF=/etc/drilltest.conf
DIR=/tmp/drilltest

[ -f "$CONF" ] || { echo "$CONF not found. Run break/01 first."; exit 1; }
id labreader >/dev/null 2>&1 || { echo "labreader doesn't exist."; exit 1; }

echo "Before:"
ls -l "$CONF"
sudo chown root:labreader "$CONF"
sudo chmod 640 "$CONF"
echo "After:"
ls -l "$CONF"

if sudo -u labreader cat "$CONF" >/dev/null 2>&1; then
    RESULT="labreader can read the config"
else
    RESULT="labreader is still blocked"
fi
if sudo -u labreader test -w "$CONF"; then
    RESULT="$RESULT but can also write it"
else
    RESULT="$RESULT and cannot write it"
fi

sudo rm -f "$CONF"

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
