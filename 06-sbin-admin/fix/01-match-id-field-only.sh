#!/bin/bash
# 06-sbin-admin/fix/01-match-id-field-only.sh
#
# Fix for break/01. Tests the ID field alone, not the whole file, so the
# family list in ID_LIKE no longer counts. Then it removes /tmp/oslab.

set -u
DIR=/tmp/oslab
COPY=$DIR/os-release

[ -f "$COPY" ] || { echo "$COPY not found. Run break/01 first."; exit 1; }

FAMILY=debian
grep -q '^ID_LIKE=.*debian' "$COPY" || FAMILY=fedora

echo "Machine: $(grep '^PRETTY_NAME=' "$COPY")"
echo "ID line: $(grep '^ID=' "$COPY")"
N=$(grep -c "^ID=\"\?$FAMILY\"\?$" "$COPY")
echo "Right test: ID equals $FAMILY -> $N"

if [ "$N" -eq 0 ]; then
    RESULT="ID is not $FAMILY, so the machine is correctly not $FAMILY"
else
    RESULT="ID is $FAMILY"
fi

rm -rf "$DIR"
[ -e "$DIR" ] && echo "RESULT: $RESULT, but $DIR is still there" || echo "RESULT: $RESULT, $DIR removed"
