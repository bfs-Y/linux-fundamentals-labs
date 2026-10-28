#!/bin/bash
# 05-users-sudo/break/02-group-added-after-start.sh
#
# A user is added to a group, id shows the group, ls -l on the file looks
# right, and a process that was already running still gets Permission
# denied, because it keeps the groups it started with. A new login sees
# the group at once. Needs sudo. Leaves the old process running until
# fix/02-restart-with-new-group.sh runs.

set -u

DIR=/tmp/groupslab
LOOP='while true; do if cat '"$DIR"'/db.conf >/dev/null 2>&1; then echo ok; else echo denied; fi >> '"$DIR"'/reader.log; sleep 1; done'

[ -e "$DIR" ] && { echo "$DIR already exists. Run the fix script first."; exit 1; }
if id labreader >/dev/null 2>&1 && id -nG labreader | tr ' ' '\n' | grep -qx labdb; then
    echo "labreader is already in labdb. Remove it first."
    exit 1
fi

if ! id labreader >/dev/null 2>&1; then
    sudo useradd -m -s /bin/bash labreader
    CREATED_USER=yes
fi
if ! getent group labdb >/dev/null; then
    sudo groupadd labdb
    CREATED_GROUP=yes
fi

mkdir "$DIR"
[ "${CREATED_USER:-}" = yes ] && touch "$DIR/.created-user"
[ "${CREATED_GROUP:-}" = yes ] && touch "$DIR/.created-group"

echo "setting=value" | sudo tee "$DIR/db.conf" > /dev/null
sudo chgrp labdb "$DIR/db.conf"
sudo chmod 640 "$DIR/db.conf"
touch "$DIR/reader.log"
sudo chown labreader "$DIR/reader.log"

sudo -u labreader sh -c "$LOOP" >/dev/null 2>&1 &
sleep 3
PID=$(pgrep -u labreader -f reader.log | head -1)
[ -n "$PID" ] || { echo "the loop did not start"; exit 1; }

echo "Before the group change. The loop's groups:"
grep Groups /proc/$PID/status
echo "Last log line: $(tail -1 "$DIR/reader.log")"
ls -l "$DIR/db.conf"

sudo usermod -aG labdb labreader
echo
echo "After usermod -aG labdb labreader, id says: $(id labreader)"
sleep 3
echo "The running loop's groups:"
grep Groups /proc/$PID/status
echo "Last log line: $(tail -1 "$DIR/reader.log")"
echo "A fresh login reads: $(sudo -u labreader cat "$DIR/db.conf" 2>&1)"

if tail -1 "$DIR/reader.log" | grep -q denied && sudo -u labreader cat "$DIR/db.conf" >/dev/null 2>&1; then
    echo "RESULT: the group is in the database and a new login reads the file, but the running process is still denied"
else
    echo "RESULT: unexpected, read the output above"
fi
