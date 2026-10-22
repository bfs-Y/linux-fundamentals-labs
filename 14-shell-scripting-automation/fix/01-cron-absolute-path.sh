#!/bin/bash
# 14-shell-scripting-automation/fix/01-cron-absolute-path.sh
#
# Fix for break/01-cron-relative-path.sh. cron starts the job in the
# account's home folder, so a relative path to the config points at a
# file that isn't there. The fix is an absolute path, and the job's
# output goes into a file so the next failure shows up somewhere.
# It only deletes the labreader account if the break script created it,
# and it only says "removed" after checking the account is really gone.
# On Rocky, sudo -u starts a short-lived systemd --user process for the
# account, and userdel refuses while it runs, so I end it and wait first.

set -u

DIR=/tmp/cronlab

[ -f "$DIR/app.conf" ] || { echo "$DIR/app.conf not found. Run break/01 first."; exit 1; }
id labreader >/dev/null 2>&1 || { echo "labreader doesn't exist."; exit 1; }

echo "What the job sees when it starts in labreader's home folder:"
sudo -u labreader sh -c 'cd "$HOME" && cat app.conf' 2>&1

ENTRY='* * * * * cat '"$DIR"'/app.conf > "$HOME/cron-out.txt" 2>&1'
echo "$ENTRY" | sudo crontab -u labreader -
echo "Replaced the job: $ENTRY"
echo "Waiting 70 seconds..."
sleep 70

OUT=$(sudo cat /home/labreader/cron-out.txt 2>&1)
echo "The job's output file says: $OUT"
if [ "$OUT" = "setting=value" ]; then
    RESULT="the job read the config under cron"
else
    RESULT="the job did not read the config"
fi

sudo crontab -u labreader -r
sudo rm -f /home/labreader/cron-out.txt /root/.cache/crontab/crontab.labreader.bak

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
