#!/bin/bash
# 06-sbin-admin/break/01-id-like-fools-grep.sh
# Run ONE break/fix pair at a time.
#
# ID_LIKE in /etc/os-release names the distro's family (debian on Ubuntu,
# "rhel centos fedora" on Rocky). A script that detects the distro with a
# plain grep over the whole file matches that line and takes a family
# name for the machine's identity. The script copies the real file to
# /tmp/oslab and runs the wrong test on the copy. It never touches
# /etc/os-release.
# Leaves /tmp/oslab in place until fix/01 runs.

set -u
DIR=/tmp/oslab
COPY=$DIR/os-release

[ -r /etc/os-release ] || { echo "/etc/os-release is not readable. Stopping."; exit 1; }
[ -e "$DIR" ] && { echo "$DIR exists. Run the fix script first."; exit 1; }

# The wrong word depends on the machine.
FAMILY=debian
grep -q '^ID_LIKE=.*debian' /etc/os-release || FAMILY=fedora
grep -q "^ID_LIKE=.*$FAMILY" /etc/os-release || { echo "No family word to test on this machine. Stopping."; exit 1; }

mkdir "$DIR"
cp /etc/os-release "$COPY"

echo "Machine: $(grep '^PRETTY_NAME=' "$COPY")"
echo "Family word being tested: $FAMILY"
N=$(grep -c "$FAMILY" "$COPY")
echo "Wrong test: grep -c $FAMILY $COPY -> $N"
grep -n "$FAMILY" "$COPY"

if [ "$N" -gt 0 ]; then
    echo "RESULT: the test says this is $FAMILY, but that word also appears in lines that are not the ID field"
else
    echo "RESULT: no match, nothing broken here"
fi
