#!/bin/bash
# Rotates a log twice with "rotate 1" and no "create", then checks whether
# the line I care about survived. Everything is in /tmp/rotatelab and
# stays there until fix/02-safe-rotation-config.sh runs.

set -u
DIR=/tmp/rotatelab
LR=/usr/sbin/logrotate

mkdir -p "$DIR" && cd "$DIR" || exit 1
rm -f app.log app.log.* state
printf '02:10 normal operation\n02:14 INCIDENT db01 disk error\n02:20 normal operation\n' > app.log
cat > rotate.conf << 'CONF'
/tmp/rotatelab/app.log {
    rotate 1
    missingok
}
CONF

"$LR" -s "$DIR/state" -f "$DIR/rotate.conf"
echo "After rotation 1:"; ls -li app.log*
echo '03:00 normal operation' >> app.log
"$LR" -s "$DIR/state" -f "$DIR/rotate.conf"
echo "After rotation 2:"; ls -li app.log*

if grep -q INCIDENT app.log* 2>/dev/null; then
    echo "RESULT: INCIDENT line still exists"
else
    echo "RESULT: INCIDENT line is gone, no error was shown"
fi
