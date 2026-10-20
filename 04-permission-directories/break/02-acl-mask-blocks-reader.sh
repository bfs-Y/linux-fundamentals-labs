#!/bin/bash
# 04-permission-directories/break/02-acl-mask-blocks-reader.sh
#
# A service account gets read access through an ACL. Then a "tighten the
# permissions" step runs chmod 600, and the ACL entry stops working while
# ls -l still shows a normal locked-down file.
# Needs sudo. Leaves the broken file in /tmp/aclcase until
# fix/02-restore-reader-access.sh runs.

set -u

DIR=/tmp/aclcase
CONF=$DIR/app.conf

if ! id labreader >/dev/null 2>&1; then
    sudo useradd -m -s /bin/bash labreader
    CREATED=yes
fi

mkdir -p "$DIR"
chmod 755 "$DIR"
[ "${CREATED:-}" = yes ] && touch "$DIR/.created-labreader"

echo "setting=value" > "$CONF"
chmod 640 "$CONF"
setfacl -m u:labreader:r-- "$CONF"

echo "Before the tightening step:"
ls -l "$CONF"
echo "labreader reads: $(sudo -u labreader cat "$CONF" 2>&1)"

echo
echo "Tightening step: chmod 600"
chmod 600 "$CONF"
ls -l "$CONF"
getfacl "$CONF" 2>/dev/null | grep -E 'labreader|mask'

if sudo -u labreader cat "$CONF" >/dev/null 2>&1; then
    echo "RESULT: labreader can still read the file"
else
    echo "RESULT: labreader is blocked, and ls -l shows a normal 600 file"
fi
