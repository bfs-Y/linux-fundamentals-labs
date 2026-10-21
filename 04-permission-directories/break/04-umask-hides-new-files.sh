#!/bin/bash
# 04-permission-directories/break/04-umask-hides-new-files.sh
#
# A script creates a config file for another account in the same group,
# but it runs with umask 077, so the file starts at mode 600 and the
# group gets nothing. ls -l shows the group is right and the mode is the
# problem. Needs sudo. Leaves the broken file in /tmp/umasklab until
# fix/04-fix-umask.sh runs.

set -u

DIR=/tmp/umasklab
F=$DIR/app.conf

if ! id labreader >/dev/null 2>&1; then
    sudo useradd -m -s /bin/bash labreader
    CREATED=yes
fi

mkdir -p "$DIR"
chmod 755 "$DIR"
[ "${CREATED:-}" = yes ] && touch "$DIR/.created-labreader"

echo "The script runs with umask 077 and hands the file to the labreader group:"
( umask 077; echo "setting=value" > "$F" )
sudo chgrp labreader "$F"
ls -l "$F"
echo "labreader reads: $(sudo -u labreader cat "$F" 2>&1)"

if sudo -u labreader cat "$F" >/dev/null 2>&1; then
    echo "RESULT: labreader can read the file"
else
    echo "RESULT: the group is right but the mode is 600, so labreader is blocked"
fi
