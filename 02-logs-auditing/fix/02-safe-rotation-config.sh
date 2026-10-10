#!/bin/bash
# Fix for break/02. Keeps four old copies, compresses them, and creates a
# new empty log after each rotation. Removes the lab folder at the end.

set -u
DIR=/tmp/rotatelab
LR=/usr/sbin/logrotate

[ -d "$DIR" ] || { echo "$DIR not found. Run break/02 first."; exit 1; }
cd "$DIR" || exit 1
rm -f app.log app.log.* state
printf '02:10 normal operation\n02:14 INCIDENT db01 disk error\n02:20 normal operation\n' > app.log
cat > rotate-fixed.conf << 'CONF'
/tmp/rotatelab/app.log {
    rotate 4
    weekly
    missingok
    notifempty
    create
    compress
    delaycompress
}
CONF

for i in 1 2 3 4; do
    "$LR" -s "$DIR/state" -f "$DIR/rotate-fixed.conf"
    echo "line $i" >> app.log
done
ls -li app.log*

if zgrep -q INCIDENT app.log*; then
    RESULT="INCIDENT line survived 4 rotations"
else
    RESULT="INCIDENT line is gone"
fi
cd / && rm -rf "$DIR"
echo "RESULT: $RESULT (lab removed)"
