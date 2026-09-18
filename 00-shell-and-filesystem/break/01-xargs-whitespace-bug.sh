#!/bin/bash
# 00-shell-and-filesystem/break/01-xargs-whitespace-bug.sh
#
# BREAK: naive `find | xargs rm` on a filename containing whitespace.
# xargs splits on whitespace by default, silently mangling the filename
# into two bogus arguments instead of one real path.

set -uo pipefail   # deliberately no -e: we WANT to see the failure, not abort on it

echo "[break] Creating test file with a space in the name..."
touch "/tmp/my file.log"

echo "[break] Attempting naive find | xargs rm (expected to fail silently)..."
find /tmp -name '*.log' | xargs rm

echo "[break] Checking survival of the file..."
ls /tmp/my*.log 2>&1
