#!/bin/bash
# 05-users-sudo/fix/02-restart-with-new-group.sh
#
# Fix for break/02-group-added-after-start.sh. The file and the group were
# never wrong. The running process keeps the groups it started with, so I
# stop it and start it again, and the new process gets the current
# groups. It only deletes the account or the group if the break script
# created them, and it checks they're really gone before it says so.
# On Rocky, sudo -u starts a short-lived systemd --user process for the
# account, and userdel refuses while it runs, so I end it and wait first.

set -u

DIR=/tmp/groupslab
LOOP='while true; do if cat '"$DIR"'/db.conf >/dev/null 2>&1; then echo ok; else echo denied; fi >> '"$DIR"'/reader.log; sleep 1; done'

[ -d "$DIR" ] || { echo "$DIR not found. Run break/02 first."; exit 1; }
id labreader >/dev/null 2>&1 || { echo "labreader doesn't exist."; exit 1; }

echo "Stopping the old process and starting it again."
sudo pkill -u labreader -f reader.log
sleep 1
sudo -u labreader sh -c "$LOOP" >/dev/null 2>&1 &
sleep 3
PID=$(pgrep -u labreader -f reader.log | head -1)
echo "The restarted process's groups:"
grep Groups /proc/$PID/status
echo "Last log line: $(tail -1 "$DIR/reader.log")"

if tail -1 "$DIR/reader.log" | grep -q ok; then
    RESULT="the restarted process reads the file"
else
    RESULT="the restarted process is still denied"
fi

sudo pkill -u labreader -f reader.log
sleep 1

NOTE="left labreader in place"
KEEP=no
if [ -f "$DIR/.created-user" ]; then
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
if [ -f "$DIR/.created-group" ]; then
    sudo groupdel labdb
    getent group labdb >/dev/null && { NOTE="$NOTE, labdb still exists"; KEEP=yes; }
fi

if [ "$KEEP" = yes ]; then
    LAB="lab folder kept"
else
    cd / && sudo rm -rf "$DIR"
    LAB="lab removed"
fi
echo "RESULT: $RESULT, $NOTE, $LAB"
